/**
 *  Intelliarts Consulting/EMC Troff01 26-jul-2013  Added file name validation (the file names should conform to DITA
 *                                              specification).
 *                                              Added uniqueness check (and the appropriate correction) for the file
 *                                              names. SH
 *
 *  Intelliarts Consulting/EMC Troff01 23-jul-2013
 *
 *  The script accumulates a logic related to filename normalization (files renaming).
 *
 *  The routine is started with copying source DITA files from the input directory to a temporary folder. The temporary
 *  folder location is then written to the {@code emctroff.input.dir} property. Then the following algorithm is being applied
 *  for each source file:
 *
 *  1.  The script identifies a kind of the input file to apply the appropriate extension. If if is a map, the source
 *      file extension is renamed to .ditamap (topic.xml => topic.ditamap).
 *
 *  2.  The script tries to load a Trisoft metadata file (*.met) associated with the current source file (topic or a map).
 *      The .met file's name root should match the file name root of the source file (topic.xml / topic.met).
 *
 *  3.  If the metadata file can be located in the initial input directory, the script extracts a field configured by
 *      XPath from {@code emctroff.filenames.xpath} property (for example, {@code /ishobject/ishfields/ishfield[@name='FTITLE']}).
 *
 *  4.  The extracted field value (or the input file name) is processed by stripping a string part matching a regular
 *      expression contained by the {@code emctroff.filenames.strip.regex} property. For instance, setting the
 *      property to {@code ^il_[A-Za-z]+_} will result in "il_br_topic.ditamap" renamed to "topic.ditamap".
 *
 *  6.  All non-alphanumeric characters, non-hyphens and non-underscores are switched to underscores.
 *
 *  7.  The script checks tests the uniqueness of the resulting file name and fixes it (if needed) by appending a number.
 *
 *  8.  Finally, the {@code args.input} DITA-OT property is being overwritten by the new path.
 *
 *  SH
 *
 **/

// Add support for 'importClass' in JAVA10
try {
    load("nashorn:mozilla_compat.js");
} catch (e) {
    // ignore the exception - perhaps we are running on Rhino!
}

importClass(java.io.File);
importClass(java.util.regex.Pattern);
importClass(java.util.UUID);

importClass(javax.xml.parsers.DocumentBuilderFactory);
importClass(javax.xml.parsers.DocumentBuilder);
importClass(org.w3c.dom.Document);

importClass(org.apache.xml.resolver.tools.CatalogResolver);
importClass(org.apache.xml.resolver.CatalogManager);

importClass(javax.xml.xpath.XPath);
importClass(javax.xml.xpath.XPathFactory);

var tasks = {
    echo: project.createTask( "echo" ),
    copy: project.createTask( "copy" ),
    move: project.createTask( "move" )
};

function XmlParser( ) {
    this.db = DocumentBuilderFactory.newInstance( ).newDocumentBuilder( );
}

XmlParser.prototype.parse = function ( file, catalogFile ) {
    if ( typeof catalogFile !== 'undefined' ) {
        var manager = new CatalogManager( );
        manager.setCatalogFiles( catalogFile.getAbsolutePath( ) );
        manager.setIgnoreMissingProperties( true );

        var resolver = new CatalogResolver( manager );
        this.db.setEntityResolver( resolver );
    }

    return this.db.parse( file );
};

function XpathEngine() {
}

XpathEngine.evaluate = function ( expression, doc ) {
    var xPath = XPathFactory.newInstance() .newXPath( );
    return xPath.compile( expression ).evaluate( doc );
};

function FileNameUtils() {

}

FileNameUtils.prototype.xmlParser = new XmlParser( );
FileNameUtils.prototype.nameXpath = project.getProperty( "emctroff.filenames.xpath" );
FileNameUtils.prototype.nameStripRegex = project.getProperty( "emctroff.filenames.strip.regex" );

FileNameUtils.getBasename = function ( fileName ) {
    return fileName.replaceAll( "(?i)\.(xml|ditamap)$", "" );
};

/*
 * Intelliarts Consulting/EMC Troff01 26-jul-2013
 * Extracts a file name from the passed Trisoft meta file using XPath set by the property "emctroff.filenames.xpath".
 * If the meta file is missing, the function returns the basename of the input file.    SH
 */
FileNameUtils.getNameFromMetaFile = function ( metaFile, file ) {
    var result;

    if ( metaFile.exists( ) ) {
        var metaFileDoc = this.prototype.xmlParser.parse( metaFile );
        result = XpathEngine.evaluate( this.prototype.nameXpath, metaFileDoc );
    } else {
        tasks.echo.setMessage( "Warning! Metafile for: '" + file.getName() + "' does not exist." );
        tasks.echo.execute();

        result = FileNameUtils.getBasename( file.getName( ) );
    }

    return result;
};

/*
 * Intelliarts Consulting/EMC Troff01 26-jul-2013
 * Strips a string part configured by evaluating a regular expression set in the "emctroff.filenames.strip.regex"
 * property. Changes any non-alphanumeric characters, non-hyphens or non-underscores into an underscore.  SH
 */
FileNameUtils.correctName = function ( fileName ) {
    var result = fileName.replaceAll( this.prototype.nameStripRegex, "" );
    return result.replaceAll( "[^A-Za-z0-9_-]", "_" );
};

/*
 * Intelliarts Consulting/EMC Troff01 26-jul-2013
 * Calculates a source file extension based on the root element's class. DITA maps are mapped to .ditamap.  SH
 */
FileNameUtils.getExtension = function ( copyDoc ) {
    var rootElementClass = copyDoc.getDocumentElement().getAttribute( "class" );

    return rootElementClass.contains("- map/map ") ?
        ".ditamap" :
        ".xml";
};

/*
 * Intelliarts Consulting/EMC Troff01 26-jul-2013
 * Ensures a uniqueness of the passed file name. If the supplied directory already contains a file with the input name,
 * a number is appended to it.  SH
 */
FileNameUtils.getUniqueName = function ( fileName, directory ) {

    function isNameUnique( name ) {
        var duplicate = new File( directory, name );
        return !duplicate.exists( );
    }

    function appendPostfix( name, postfix ) {
        return name.replaceFirst( ".(?=(ditamap|xml$))", postfix + "." );
    }

    var result = fileName;
    var i = 1;
    while ( !isNameUnique( result ) ) {
        result = appendPostfix( fileName, i );
        i++;
    }
    return result;
};


(function () {

    function getSources( ) {
        var sourcesFs = project.createDataType( "fileset" );
        sourcesFs.setDir( inputDirectory );
        sourcesFs.setIncludes ( [ "**/*.xml", "**/*.ditamap" ] );

        return sourcesFs.getDirectoryScanner( project ).getIncludedFiles( );
    }

    function copySources( sources ) {
        var tempDirectory = new File( inputDirectory, UUID.randomUUID() );
        tempDirectory.mkdir( );

        for ( i = 0; i < sources.length; i++ ) {
            var source = new File( inputDirectory, sources[i] );

            tasks.copy.setFile( source );
            tasks.copy.setTodir( tempDirectory );
            tasks.copy.execute( );
        }
        project.setProperty( DITA_DIR_TEMP_PROPERTY, tempDirectory.getAbsolutePath( ) );

        return tempDirectory;
    }

    function getMetaFile( source ) {
        var name = source.getName( );
        var nameWithoutExtension = FileNameUtils.getBasename( name );

        return new File( inputDirectory, nameWithoutExtension + ".met" );
    }

    function getCopy( source, tempDirectory ) {
        var name = source.getName( );
        return new File( tempDirectory, name );
    }

    /**
     * Calculates a destination file name.
     * @param meta the meta file descriptor for the actual input.
     * @param copy the copy of a DITA source file, located in a temporary directory.
     * @param copyDoc the copy, parsed.
     * @returns {*} the destination file name.
     */
    function getDestinationFileName( meta, copy, copyDoc ) {
        var result = FileNameUtils.getNameFromMetaFile( meta, copy );
        result = FileNameUtils.correctName( result );
        result = result.concat( FileNameUtils.getExtension( copyDoc ) );
        return FileNameUtils.getUniqueName( result, copy.getParentFile( ) );
    }

    function renameFile( source, destination ) {
        tasks.move.setFile( source );
        tasks.move.setTofile( destination );
        tasks.move.execute();
    }

    /**
     * Intelliarts Consulting/EMC Troff01 23-jul-2013
     * Updates references to a renamed DITA source file. By "references" {@code conref} and {@code href} attribute
     * values are meant. The regular expression pattern behind the renaming is stored by the
     * {@code REF_REPLACE_REGEX_PATTERN} variable.  SH
     *
     * @param referencedFile the referenced file.
     * @param encoding the encoding of the referenced file
     * @param files the files to update the file reference in.
     * @param newReference the new file name.
     */
    function updateReferences( referencedFile, encoding, files, newReference ) {
        var basename = FileNameUtils.getBasename( referencedFile.getName() );

        var expression = REF_REPLACE_REGEX_PATTERN.replace( REF_REPLACE_OLD_NAME_TOKEN,
            Pattern.quote( basename ) );

        var replaceRegexpTask = project.createTask( "replaceregexp" );
        replaceRegexpTask.addFileset( files );
        replaceRegexpTask.setMatch( expression );
        replaceRegexpTask.setFlags( "g" );
        replaceRegexpTask.setReplace( newReference );
        replaceRegexpTask.setByLine( true );
        replaceRegexpTask.setEncoding( encoding );
        replaceRegexpTask.execute( );
    }

    /**
     * Intelliarts Consulting/EMC Troff01 23-jul-2013
     * Renames DITA source file copy and update the references to it ({@code conref}, {@code href}).    SH
     *
     * @param copy a copy of a DITA source file located in a temporary directory.
     * @param meta a {File} reference to the associated Trisoft metadata file.
     * @param tempDirectory the temporary directory containing DITA copies.
     * @returns {File} the resulting file.
     */
    function processSource( copy, meta, tempDirectory ) {
        var sourceCopiesFs = project.createDataType( "fileset" );
        sourceCopiesFs.setDir( tempDirectory );

        var copyDoc = xmlParser.parse( copy, catalogDitaFile );
        var destinationName = getDestinationFileName( meta, copy, copyDoc );
        var destination = new File( tempDirectory, destinationName );

        //  Intelliarts Consulting/EMC Troff01 26-jul-2013
        // If destination name is different from the source name, print the message and rename the file.    SH
        if ( !copy.getName().equals( destinationName )) {
            tasks.echo.setMessage( "Renaming: '" + copy.getName() + "' to: '" + destinationName + "'." );
            tasks.echo.execute( );

            renameFile( copy, destination );
        }

        //  Intelliarts Consulting/EMC Troff01 26-jul-2013
        // References to the file should be updated in any case, since DITA sources may contain hrefs and conrefs
        // without extensions (GUID-X-X-X-X-X) which won't work if the input directory is modified.
        updateReferences( copy, copyDoc.getInputEncoding( ), sourceCopiesFs, destinationName );

        return destination;
    }

    /**
     * Intelliarts Consulting/EMC Troff01 23-jul-2013
     * Iterates through DITA source files, processes them as described in the script description, and updates
     * the {@code args.input} value to match the new path of an input file.   SH
     *
     * @param sources the source files to process.
     * @param tempDirectory a temporary directory created to store the renamed files.
     */
    function processSources( sources, tempDirectory ) {
        for ( i = 0; i < sources.length; i++ ) {
            var source = new File( inputDirectory, sources[i] );
            var copy = getCopy( source, tempDirectory );
            var meta = getMetaFile( source );

            var destination = processSource( copy, meta, tempDirectory );

            if ( inputFile.getName().equals( source.getName( ) ) ) {
                project.setUserProperty( "args.input", destination.getAbsolutePath( ) );
            }
        }
    }

    // Intelliarts Consulting/EMC Troff01 23-jul-2013   Initialize common data and invoke the file processing.   SH

    var REF_REPLACE_REGEX_PATTERN = "(?<=[^A-Za-z](h|con)ref=\")(@OLD_NAME@(.xml|.ditamap?)?)(?=(#[^\"]*)?\")";
    var REF_REPLACE_OLD_NAME_TOKEN = "@OLD_NAME@";

    var DITA_DIR_TEMP_PROPERTY = "emctroff.input.dir";

    var inputFile = new File( project.getProperty( "args.input" ) );
    var inputDirectory = inputFile.getParentFile( );
    var catalogDitaFile = new File("C:\\Users\\Iryna_Barinova\\IdeaProjects\\EMC2DELL_migration\\data\\dita-catalogs\\dell-catalogs\\catalog.xml");
    // var catalogDitaFile = new File( project.getProperty( "dita.dir" ), "catalog-dita.xml" );

    var xmlParser = new XmlParser( );

    var sources = getSources( );

    processSources( sources, copySources( sources ) );

}());
