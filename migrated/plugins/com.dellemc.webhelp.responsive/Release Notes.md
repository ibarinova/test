//TODO First Release notes

###09.20.2018 Drop1:

#####Changes list:
*   **IDPL-3739**: Automatic text before selected elements missing in general,  
    **IDPL-3751**: Expand/Collapse based on outputclass="show_hide" not implemented:  
        *resources/js/expand.js* - Changed selectors for expand elements.  
        *templates/dellemc.template/resources/css/topic.css* - Added style for task label.  
        *xsl/dita2webhelp/task.xsl* - Changed rule for processing steps tag.   
        *xsl/dita2webhelp/topic.xsl* - Added rule for processing title inside example.  

*   **IDPL-3732**: EMC Web Help Phase 1: Document title wrapped over multiple lines:
        *templates/dellemc.template/resources/css/main.css* - Changed style for publication title.
    
*   **IDPL-3712**: EMC Web Help Phase 1: Menu format change based on window size is broken:
        *templates/dellemc.template/resources/css/main.css* - Changes styles for top menu.  
        *templates/dellemc.template/dellemc-tiles.opt* - Set depth for displayed elements in top menu.   
        *oxygen-webhelp/page-templates/wt_topic.html* - Changed class in navigation block.  
        
        
###09.27.2018 Drop2:

#####Changes list:
*   **IDPL-3733**: Table description displaying after title:  
        *templates/dellemc.template/resources/css/topic.css* - added style for table description element.  
        *xsl/dita2webhelp/table.xsl* - changed rule for processing table.  
        
*   **IDPL-3735**: Footer.xml appears at bottom of Search results:  
        *oxygen-webhelp/page-templates/wt_search.html* - removed footer from search page template.
         
*   **IDPL-3734**: Image zoom responsiveness:  
        *templates/dellemc.template/resources/css/topic.css*: changed style for modal image.
          
*   **IDPL-3917**: Manual Cross-Reference Links within text are broken because they use GUIDs instead of ftitle:  
        *build.xml*: added prepreocessing for topic references.
        
*   **IDPL-3741**: Footnotes are not added consistently in regular text?,  
    **IDPL-3742**: Table footnotes notes not working as expected:  
        *xsl/dita2webhelp/topic.xsl* - changed rule for processing footnotes.  
        *xsl/dita2webhelp/table.xsl* - changed rule for processing tables with nested footnotes.  
        *xsl/dita2webhelp/simpletable.xsl* - changed rule for processing simple tables with nested footnotes.  
        *xsl/dita2webhelp/reference.xsl* - changed rule for processing reference with nested footnotes.  
        
*   **IDPL-3915**: Various extraneous XML files appear in output:  
        *com.dellemc.webhelp.responsive/build.xml*: added target for cleanup files.  
        
*  **IDPL-3749**: Parts do not work correctly:  
        *templates/dellemc.template/resources/css/main.css* - changed style for part item in sidetoc.  
        *xsl/navLinks/tocDitaImpl.xsl* - Changed rule for generating sidetoc references.  
        
*   **IDPL-3916** - Previous next controls duplicated under certain circumstances:  
        *xsl/dita2webhelp/dita2xhtml.xsl* - added rule for generating navigation header.  

*   **IDPL-3752**: Context-Sensitive Help not implemented:  
        *xsl/plugin-preprocess/generate-context-sensitive-help-js.xsl* - added rules for generating help.js file.  
        *xsl/plugin-preprocess/generate-context-sensitive-help-xml.xsl* - added rules for generating map.xml file.  
        *xsl/plugin-preprocess/generate-context-sensitive-help-xml-cleanup.xsl* - added rules for cleanup map.xml file.  
        *build.xml* - added target for generating contex sensitive help.  

###09.28.2018 Drop3:

#####Changes list:
*   **IDPL-3897**: Example autotext appears in too large a font compared to other automatic text:  
        *xsl/dita2webhelp/topic.xsl* - changed generated .class for example label.  

*   **IDPL-3920**: DRAFT messages are tacked onto name, should appear on a separate line:  
        *xsl/template/commonComponentsExpander.xsl* - added span wrapper for draft and rsa publication title prefix.  
        *templates/dellemc.template/resources/css/main.css* - changed styles for publication title.  
        
*   **IDPL-3903**: DITA transformed intermediate text are added in html source,  
    **IDPL-3770**: Is auto-generated content section expected?:  
        *xsl/dita2webhelp/fixup.xsl* - redefined template name generateHeadContent.  
        *xsl/template/commonComponentsExpander.xsl* - redefined template name add-toc-id.  
        
*   **IDPL-3711**: Parts of color scheme not correct:  
        *templates/dellemc.template/resources/css/main.css* - changed styles for popup and breadcrumbs menu.  

*   **IDPL-3737**: Opening index.html opens wrong topic, displays wrong text in tab at top of browser:  
        *xsl/dita2webhelp/topic.xsl* - changed rule for generating topic page meta title.  
        *xsl/template/commonComponentsExpander.xsl* - changed rule for generating search page meta title.  
        *xsl/mainFiles/createMainPageImpl.xsl* - changed redirection from index.html.  

*   **IDPL-3737**: Non-Draft version of the "HTML5 Web Help - RSA" output includes the RSA CONFIDENTIAL language:  
          *xsl/template/commonComponentsExpander.xsl* - removed publication title prefix for RSA output.  
          
*   **IDPL-3754**: Calling a topic using ?topic=resourceid doesn't work,  
    **IDPL-3753**: calling a topic using # does not work.  
        **oxygen-webhelp/page-templates/wt_index.html** - added script for redirecting index page.
        
*   **IDPL-3921**: Cannot figure out how to get video to scale.  
        *xsl/dita2webhelp/topic.xsl* - changed rule for generating iframe element.  
        *templates/dellemc.template/resources/css/topic.css* - changed styles for iframe element.  
        
###10.05.2018 Drop4:
        
#####Changes list:
*   **IDPL-3929**: Previous / Next icons do not look right in IE.  
        *templates/dellemc.template/resources/css/topic.css* - changed styles for nav buttons.  
        
*   **IDPL-3929**: conref and keyref content left out in navigation.  
        *xsl/navLinks/tocDitaImpl.xsl* - Changed rule for generating toc.  
        
*   **IDPL-3754**: Calling a topic using ?topic=resourceid doesn't work  
        **oxygen-webhelp/page-templates/wt_index.html** - fixed script for redirecting pages.  
        
*   **IDPL-3932**: Roboto and Noto fonts need to be embedded in Web Help CSS (similar to how meta font was embedded prior).  
        *templates/dellemc.template/resources/css/main.css*  
        *templates/dellemc.template/resources/css/topic.css* - changed font rules.  
        *xsl/template/commonComponentsExpander.xsl* - added language param.

###10.18.2018 Drop5:
        
#####Changes list:
*   **IDPL-3931**: elements such as <cite> element in various languages do not display correctly.  
        *templates/dellemc.template/resources/css/topic.css* - add css rule for no-italic class.  
        *xsl/dita2webhelp/topic.xsl* - redefined rules for: cite, q, option, uicontrol, var, varname, wintitle.  
        
*   **IDPL-4089**: The "Home" and "Collapse Sections" text not translated in web help,  
*   **IDPL-4082**: Chinese publication search placeholder value is untranslated.  
        *xsl/mainFiles/createLocalizationFile.xsl* - fix oxygen bug with locallization extensions.  
        *com.dellemc.common.resources/strings/strings-en-us.xml* - added translation strings for english localizations.  
        
###10.25.2018 Drop6:
        
#####Changes list:
*   **IDPL-3749**: Parts do not work correctly.  
        *xsl/navLinks/sidetoc.xsl* - added onclick="return false" for bookmat in side TOC.
        *build.xml*: extended target whr-nav-links.  
        *templates/dellemc.template/resources/css/main.css* - Changed style for bookmap links in TOC.  
          
*   **IDPL-4097**: Parts do not work correctly.
        *xsl/dita2webhelp/topic.xsl* - changed rule for generating html header.  
        *xsl/template/commonComponentsExpander.xsl* - changed rule for processing html header, added script for changing document title.
        
*   **IDPL-4213**: Heading location is inconsistent.  
        *templates/dellemc.template/resources/css/main.css* - changed style for heading.  
        
*   **IDPL-4138**: No Prev / Next arrows for tablet / phone view makes it hard to navigate.    
        *templates/dellemc.template/resources/css/main.css* - changed style for navigation arrows.  
        
*   **IDPL-4215**: Spacing too wide above table.      
        *templates/dellemc.template/resources/css/main.css* - changed style for tables.  
        
*   **IDPL-3736**: Fortify flag on cross-site forging.  
        **xsl/mainFiles/createMainPageImpl.xsl** - added generating script for redirecting index page.  
        **oxygen-webhelp/page-templates/wt_index.html** - removed script.    
        **build.xml**: redefined whr-create-main-page.  
        
###10.29.2018 Drop7:
        
#####Changes list:
*   **IDPL-4225**: Issues with Part ... index.html does not goes to broken page due to something related to a GUID in URL.  
        *xsl/mainFiles/createMainPageImpl.xsl* - fixed path to the first NON-bridge topic from TOC.
          
*   **IDPL-4207**: Spacing incorrect around <userinput> element.  
        *templates/dellemc.template/resources/css/topic.css* - set \<kbd\> 'padding' equal  '0'.
          
*   **IDPL-4218**: No space added between series and prodname when building the title.  
        *xsl/template/commonComponentsExpander.xsl* - add space between series and prodname.
          
*   **IDPL-3931**: elements such as <cite> element in various languages do not display correctly.  
        *templates/dellemc.template/resources/css/topic.css* - fix font style for \<option\> and \<wintitle\>.
        *xsl/dita2webhelp/topic.xsl* - add proper className for \<var\> and \<varname\> elements.
          
*   **IDPL-4235**: Suppress Chapter Folder functionality not working.  
        *xsl/plugin-preprocess/prepare-content.xsl* - remove from TOC chapters with @outputclass='no_help_folder'.
        *xsl/plugin-preprocess/generate-properties-file.xsl* - remove from TOC chapters with @outputclass='no_help_folder'.
        

 ###10.29.2018 Drop8:       

#####Changes list:
*   **IDPL-4138**: No Prev / Next arrows for tablet / phone view makes it hard to navigate.    
        *templates/dellemc.template/resources/css/main.css* - changed style for navigation arrows.  
        
*   **IDPL-4224**: : Menu subitems overlap main items in view.  
        *templates/dellemc.template/resources/css/main.css* - changed style hamburger menu items.  

*   **IDPL-4217**: table borders do not obey table settings.    
        *templates/dellemc.template/resources/css/topic.css* - redefined default webhelp rules for table borders.   

*   **IDPL-4217**: Providing a Homepage button.  
        *com.dellemc.webhelp.responsive\oxygen-webhelp\page-templates\wt_search.html* - added string for phrase "Search results".  
         *templates/dellemc.template/resources/css/topic.css* - added styles for "Home" link on a search page.  
         *xsl/template/searchPageComponentsExpander.xsl* - added rules for generating "Home" link on the search page.  
         *oxygen-webhelp/page-templates/wt_search.html* - added breadcrum panel to search template.    
               
                       
 ###10.31.2018 Drop9:       

#####Changes list:
*   **IDPL-4237**: Reltable cross references are broken.    
        *xsl/plugin-preprocess/fix-topic-xrefs.xsl* - fix href for related links without role.            
        *xsl/plugin-preprocess/generate-properties-file.xsl* - skip processing of topicmeta in order to remove title text from properties.xml.            
        *xsl/plugin-preprocess/prepare-content.xsl* - remove empty @copy-to if referenced file doesn't exist   
        
*   Added localization strings.  
        
###10.31.2018 Drop10:
*   **IDPL-4089**: EMC Web Help Phase 1: The "Home" and "Collapse Sections" text not translated in web help  
        *com.dellemc.common.resources/strings/* - changed strings for supporting by JS.
    
###11.14.2018 Drop11:
*   **IDPL-4346**: EMC Web Help Phase 1: Translations missing for search results.  
        *com.dellemc.common.resources/strings/* - add supporting by JS for 'Search no results' and 'Results for:' strings.          

###11.27.2018 Drop12:
*   **IDPL-3754**: EMC Web Help Phase 1: Calling a topic using ?topic=resourceid doesn't work.
        *xsl/mainFiles/createMainPageImpl.xsl* - fixed script which tracks current window location and loads required topic by resourceID. 
        Move this JS code to separate dynamically generated 'oxygen-webhelp/app/topic-loader.js' file in order to use it in all topic html files.  
        *xsl/template/commonComponentsExpander.xsl* - add link to topic-loader.js in topic \<head\>;
         
          
###12.17.2018 Drop13:

#####Changes list:
*   *Release Notes.md*
*   *build.xml* - add option to suppress stars in webHelp search.
*   *resources/js/expand.js* - add \<example\> element to selectors for twisties.
*   *resources/css/topic.css* - add option to suppress stars in webHelp search.
*   *resources/css/admonitions.css* - Change the look and feel for all admonitions.
    
*   *templates/dellemc.template/resources/images*- add new admonition images:
    - caution.svg;
    - caution.png;
    - note.png;
    - note.svg;
    - danger.png;
    - danger.svg;
    - warning.png;
    - warning.svg;
    
*    xsl/dita2webhelp
        *dita2xhtml.xsl* - Add support for DELL 'task-label' othermeta parameter.
        *task.xsl* - Add support for DELL 'task-label' othermeta parameter.
        *topic.xsl* - Change the look and feel for all admonitions;
            Fixed missing twisties processing for \<example\> element.
    
*   xsl/template :
    	*searchPageComponentsExpander.xsl* - add option to suppress stars in webHelp search.

###12.18.2018 Drop14:
*   Fix missed 'Draft', 'RSA' and 'RSA-Draft' main titles prefixes.
        *build.xml* - Push required 'DRAFT' and 'ARGS.BU' properties to XSL transformation.  
        *xsl/mainFiles/createMainPageImpl.xsl* - Add required 'DRAFT' and 'ARGS.BU' properties.
        *xsl/mainFiles/createSearchPageImpl.xsl* - Add required 'DRAFT' and 'ARGS.BU' properties.
        *xsl/dita2webhelp/dita2webhelpImpl.xsl* - Add required 'DRAFT' and 'ARGS.BU' properties.
        *templates/dell.template/resources/css/admonitions.css* - Fix admonition width inside list.
         
          
###02.07.2019 Drop15:
*   Apply formatting changes to following elements (IDPL-5181) : parmname, synph, msgph, systemoutput.
        *templates/dellemc.template/resources/css/topic.css*           
          
###02.14.2019 Drop16:
*   IDPL-5139 - HTML5 Web Help Publishing Failing in L-EMC Production and L-EMC Stage and Merged Env.
    Fixed processing of bridge chapter. 
        *xsl/navLinks/tocDitaImpl.xsl*           
     
          
###03.14.2019 Drop17:
*   IDPL-5502: Admonitions in PDF and HTML5 outputs is bold.
    Remove bold font size for first node in admonition.. 
        *xsl/dita2webhelp/topic.xsl*           
