<!-- ============================================================= -->
<!--                   ARCHITECTURE ENTITIES                       -->
<!-- ============================================================= -->
<!-- default namespace prefix for DITAArchVersion attribute can be
     overridden through predefinition in the document type shell   -->
<!ENTITY % DITAArchNSPrefix
  "ditaarch" 
>

<!-- must be instanced on each topic type                          -->
<!ENTITY % arch-atts 
             "xmlns:%DITAArchNSPrefix; 
                        CDATA 
                                  #FIXED 'http://dita.oasis-open.org/architecture/2005/'
              %DITAArchNSPrefix;:DITAArchVersion
                        CDATA 
                                  '1.2'
  "
>


<!-- ============================================================= -->
<!--                   SPECIALIZATION OF DECLARED ELEMENTS         -->
<!-- ============================================================= -->
<!ENTITY % cli-info-types 
                        "no-topic-nesting"                           >

<!-- ============================================================= -->
<!--                   ELEMENT NAME ENTITIES                       -->
<!-- ============================================================= -->
<!ENTITY % cli_reference          "cli_reference"                    >
<!ENTITY % cli_body               "cli_body"                         >
<!ENTITY % cli_syntax             "cli_syntax"                       >
<!ENTITY % cli_prereq             "cli_prereq"                       >
<!ENTITY % cli_description        "cli_description"                  >
<!ENTITY % cli_arguments          "cli_arguments"                    >
<!ENTITY % cli_parameters         "cli_parameters"                   >
<!ENTITY % cli_postreq            "cli_postreq"                      >
<!ENTITY % cli_args               "cli_args"                         >
<!ENTITY % cli_arg                "cli_arg"                          >
<!ENTITY % cli_arg_value          "cli_arg_value"                    >
<!ENTITY % cli_arg_desc           "cli_arg_desc"                     >
<!ENTITY % cli_options            "cli_options"                      >
<!ENTITY % cli_options_head       "cli_options_head"                 >
<!ENTITY % cli_option_type        "cli_option_type"                  >
<!ENTITY % cli_option             "cli_option"                       >
<!ENTITY % cli_option_value       "cli_option_value"                 >
<!ENTITY % cli_option_desc        "cli_option_desc"                  >
<!ENTITY % cli_params             "cli_params"                       >
<!ENTITY % cli_param              "cli_param"                        >
<!ENTITY % cli_param_value        "cli_param_value"                  >
<!ENTITY % cli_param_desc         "cli_param_desc"                   >
<!ENTITY % cli_backend_output     "cli_backend_output"               >
<!ENTITY % cli_example            "cli_example"                      >
<!ENTITY % cli_where              "cli_where"                        >

<!-- ============================================================= -->
<!--                    DOMAINS ATTRIBUTE OVERRIDE                 -->
<!-- ============================================================= -->
<!ENTITY included-domains   ""                                       >

<!-- ============================================================= -->
<!--                    ELEMENT DECLARATIONS                       -->
<!-- ============================================================= -->
<!ENTITY % cli.reference.content
                       "((%title;), 
                         (%titlealts;)?,
                         (%shortdesc;)?, 
                         (%prolog;)?, 
                         (%cli_body;)?, 
                         (%related-links;)?, 
                         (%cli-info-types;)*)"             >
<!ELEMENT cli_reference    %cli.reference.content;                    >
<!ATTLIST cli_reference  
             ishlabelxpath CDATA #FIXED "./title | @alt | @href | @conref | self::*[@id and not(@varid)]/@id"
             ishlinkxpath CDATA #FIXED "@conref | @href[contains(parent::*/@class,&apos; topic/image &apos;) and not(parent::*/@conref)]"
             id         ID                               #REQUIRED
             conref     CDATA                            #IMPLIED
             %select-atts;
             outputclass 
                        CDATA                            #IMPLIED
             xml:lang   NMTOKEN                          #IMPLIED
             %arch-atts;
             domains    CDATA                  "&included-domains;"   >

<!ENTITY % cli.body.content
                       "(%cli_syntax;, 
                         (%cli_prereq;)?,
                         %cli_description;,
                         (%cli_postreq;)?, (%cli_args;)?,
                         (%cli_options;)*, (%cli_params;)?,
                         (%cli_backend_output;)?, (%cli_example;)*)"  >
<!ELEMENT cli_body    %cli.body.content;                              >
<!ATTLIST cli_body         
             ishlabelxpath CDATA #FIXED "./title | @alt | @href | @conref | self::*[@id and not(@varid)]/@id"
             ishlinkxpath CDATA #FIXED "@conref | @href[contains(parent::*/@class,&apos; topic/image &apos;) and not(parent::*/@conref)]"
             %id-atts;
             translate  (yes | no)                       #IMPLIED
             xml:lang   NMTOKEN                          #IMPLIED
             outputclass 
                        CDATA                            #IMPLIED    >

						
						
						
						
						
						
						
						
						
						
<!ELEMENT cli_syntax  (%ph;)*                                        >
<!ATTLIST cli_syntax
             ishlabelxpath CDATA #FIXED "./title | @alt | @href | @conref | self::*[@id and not(@varid)]/@id"
             ishlinkxpath CDATA #FIXED "@conref | @href[contains(parent::*/@class,&apos; topic/image &apos;) and not(parent::*/@conref)]"
             spectitle  CDATA                            #IMPLIED
             %univ-atts;
             outputclass 
                        CDATA                            #IMPLIED    >

<!ELEMENT cli_prereq      (%section.cnt;)*                           >
<!ATTLIST cli_prereq
             ishlabelxpath CDATA #FIXED "./title | @alt | @href | @conref | self::*[@id and not(@varid)]/@id"
             ishlinkxpath CDATA #FIXED "@conref | @href[contains(parent::*/@class,&apos; topic/image &apos;) and not(parent::*/@conref)]"
             spectitle  CDATA                            #IMPLIED
             %univ-atts;
             outputclass 
                        CDATA                            #IMPLIED    >

<!ELEMENT cli_description (%section.cnt;)*                           >
<!ATTLIST cli_description
             ishlabelxpath CDATA #FIXED "./title | @alt | @href | @conref | self::*[@id and not(@varid)]/@id"
             ishlinkxpath CDATA #FIXED "@conref | @href[contains(parent::*/@class,&apos; topic/image &apos;) and not(parent::*/@conref)]"
             spectitle  CDATA                            #IMPLIED
             %univ-atts;
             outputclass 
                        CDATA                            #IMPLIED    >

<!ELEMENT cli_postreq      (%section.cnt;)*                          >
<!ATTLIST cli_postreq
             ishlabelxpath CDATA #FIXED "./title | @alt | @href | @conref | self::*[@id and not(@varid)]/@id"
             ishlinkxpath CDATA #FIXED "@conref | @href[contains(parent::*/@class,&apos; topic/image &apos;) and not(parent::*/@conref)]"
             spectitle  CDATA                            #IMPLIED
             %univ-atts;
             outputclass 
                        CDATA                            #IMPLIED    >

<!ELEMENT cli_args      ((%cli_arg;)+)                              >
<!ATTLIST cli_args
             ishlabelxpath CDATA #FIXED "./title | @alt | @href | @conref | self::*[@id and not(@varid)]/@id"
             ishlinkxpath CDATA #FIXED "@conref | @href[contains(parent::*/@class,&apos; topic/image &apos;) and not(parent::*/@conref)]"
             relcolwidth 
                        CDATA                            #IMPLIED
             keycol     NMTOKEN                          #IMPLIED
             refcols    NMTOKENS                         #IMPLIED
             %display-atts;
             spectitle  CDATA                            #IMPLIED
             %univ-atts;
             outputclass 
                        CDATA                            #IMPLIED    >

<!ELEMENT cli_arg     (%cli_arg_value;, %cli_arg_desc;)              >
<!ATTLIST cli_arg
             ishlabelxpath CDATA #FIXED "./title | @alt | @href | @conref | self::*[@id and not(@varid)]/@id"
             ishlinkxpath CDATA #FIXED "@conref | @href[contains(parent::*/@class,&apos; topic/image &apos;) and not(parent::*/@conref)]"
             %univ-atts;
             outputclass 
                        CDATA                            #IMPLIED    >

<!ELEMENT cli_arg_value (%ph.cnt;)*                                  >
<!ATTLIST cli_arg_value
             ishlabelxpath CDATA #FIXED "./title | @alt | @href | @conref | self::*[@id and not(@varid)]/@id"
             ishlinkxpath CDATA #FIXED "@conref | @href[contains(parent::*/@class,&apos; topic/image &apos;) and not(parent::*/@conref)]"
             specentry  CDATA                            #IMPLIED
             %univ-atts;
             outputclass 
                        CDATA                            #IMPLIED    >

<!--                    LONG NAME: EMC Command Line Arg    Descrip -->
<!ELEMENT cli_arg_desc (%desc.cnt;)*                                 >
<!ATTLIST cli_arg_desc
             ishlabelxpath CDATA #FIXED "./title | @alt | @href | @conref | self::*[@id and not(@varid)]/@id"
             ishlinkxpath CDATA #FIXED "@conref | @href[contains(parent::*/@class,&apos; topic/image &apos;) and not(parent::*/@conref)]"
             specentry  CDATA                            #IMPLIED
             %univ-atts;                                  
             outputclass 
                        CDATA                            #IMPLIED    >

<!ELEMENT cli_options   ((%cli_options_head;)?, (%cli_option;)+)     >
<!ATTLIST cli_options
             ishlabelxpath CDATA #FIXED "./title | @alt | @href | @conref | self::*[@id and not(@varid)]/@id"
             ishlinkxpath CDATA #FIXED "@conref | @href[contains(parent::*/@class,&apos; topic/image &apos;) and not(parent::*/@conref)]"
             relcolwidth 
                        CDATA                            #IMPLIED
             keycol     NMTOKEN                          #IMPLIED
             refcols    NMTOKENS                         #IMPLIED
             %display-atts;
             spectitle  CDATA                            #IMPLIED
             %univ-atts;
             outputclass 
                        CDATA                            #IMPLIED    >

<!ELEMENT cli_options_head (%cli_option_type;)?                      >
<!ATTLIST cli_options_head
             ishlabelxpath CDATA #FIXED "./title | @alt | @href | @conref | self::*[@id and not(@varid)]/@id"
             ishlinkxpath CDATA #FIXED "@conref | @href[contains(parent::*/@class,&apos; topic/image &apos;) and not(parent::*/@conref)]"
             %univ-atts;
             outputclass 
                        CDATA                            #IMPLIED    >

<!ELEMENT cli_option_type (%ph.cnt;)*                                >
<!ATTLIST cli_option_type
             ishlabelxpath CDATA #FIXED "./title | @alt | @href | @conref | self::*[@id and not(@varid)]/@id"
             ishlinkxpath CDATA #FIXED "@conref | @href[contains(parent::*/@class,&apos; topic/image &apos;) and not(parent::*/@conref)]"
             specentry  CDATA                            #IMPLIED
             %univ-atts;
             outputclass 
                        CDATA                            #IMPLIED    >

<!ELEMENT cli_option  (%cli_option_value;, %cli_option_desc;)        >

<!ATTLIST cli_option
             ishlabelxpath CDATA #FIXED "./title | @alt | @href | @conref | self::*[@id and not(@varid)]/@id"
             ishlinkxpath CDATA #FIXED "@conref | @href[contains(parent::*/@class,&apos; topic/image &apos;) and not(parent::*/@conref)]"
             %univ-atts;
             outputclass 
                        CDATA                            #IMPLIED    >

<!ELEMENT cli_option_value (%ph.cnt;)*                               >
<!ATTLIST cli_option_value
             ishlabelxpath CDATA #FIXED "./title | @alt | @href | @conref | self::*[@id and not(@varid)]/@id"
             ishlinkxpath CDATA #FIXED "@conref | @href[contains(parent::*/@class,&apos; topic/image &apos;) and not(parent::*/@conref)]"
             specentry  CDATA                            #IMPLIED
             %univ-atts;
             outputclass 
                        CDATA                            #IMPLIED    >

<!ELEMENT cli_option_desc (%desc.cnt;)*                              >
<!ATTLIST cli_option_desc
             ishlabelxpath CDATA #FIXED "./title | @alt | @href | @conref | self::*[@id and not(@varid)]/@id"
             ishlinkxpath CDATA #FIXED "@conref | @href[contains(parent::*/@class,&apos; topic/image &apos;) and not(parent::*/@conref)]"
             specentry  CDATA                            #IMPLIED
             %univ-atts;                                  
             outputclass 
                        CDATA                            #IMPLIED    >

<!ELEMENT cli_params    ((%cli_param;)+)                             >
<!ATTLIST cli_params
             ishlabelxpath CDATA #FIXED "./title | @alt | @href | @conref | self::*[@id and not(@varid)]/@id"
             ishlinkxpath CDATA #FIXED "@conref | @href[contains(parent::*/@class,&apos; topic/image &apos;) and not(parent::*/@conref)]"
             relcolwidth 
                        CDATA                            #IMPLIED
             keycol     NMTOKEN                          #IMPLIED
             refcols    NMTOKENS                         #IMPLIED
             %display-atts;
             spectitle  CDATA                            #IMPLIED
             %univ-atts;
             outputclass 
                        CDATA                            #IMPLIED    >

<!ELEMENT cli_param     (%cli_param_value;, %cli_param_desc;)            >
<!ATTLIST cli_param
             ishlabelxpath CDATA #FIXED "./title | @alt | @href | @conref | self::*[@id and not(@varid)]/@id"
             ishlinkxpath CDATA #FIXED "@conref | @href[contains(parent::*/@class,&apos; topic/image &apos;) and not(parent::*/@conref)]"
             %univ-atts;
             outputclass 
                        CDATA                            #IMPLIED    >

<!ELEMENT cli_param_value (%ph.cnt;)*                                >
<!ATTLIST cli_param_value
             ishlabelxpath CDATA #FIXED "./title | @alt | @href | @conref | self::*[@id and not(@varid)]/@id"
             ishlinkxpath CDATA #FIXED "@conref | @href[contains(parent::*/@class,&apos; topic/image &apos;) and not(parent::*/@conref)]"
             specentry  CDATA                            #IMPLIED
             %univ-atts;
             outputclass 
                        CDATA                            #IMPLIED    >

<!ELEMENT cli_param_desc (%desc.cnt;)*                               >
<!ATTLIST cli_param_desc
             ishlabelxpath CDATA #FIXED "./title | @alt | @href | @conref | self::*[@id and not(@varid)]/@id"
             ishlinkxpath CDATA #FIXED "@conref | @href[contains(parent::*/@class,&apos; topic/image &apos;) and not(parent::*/@conref)]"
             specentry  CDATA                            #IMPLIED
             %univ-atts;                                  
             outputclass 
                        CDATA                            #IMPLIED    >

<!ELEMENT cli_backend_output (%section.cnt;)*                        >
<!ATTLIST cli_backend_output
             ishlabelxpath CDATA #FIXED "./title | @alt | @href | @conref | self::*[@id and not(@varid)]/@id"
             ishlinkxpath CDATA #FIXED "@conref | @href[contains(parent::*/@class,&apos; topic/image &apos;) and not(parent::*/@conref)]"
             spectitle  CDATA                            #IMPLIED
             %univ-atts;                                  
             outputclass 
                        CDATA                            #IMPLIED    >

<!ELEMENT cli_example (%section.cnt;)*                    >
<!ATTLIST cli_example
             ishlabelxpath CDATA #FIXED "./title | @alt | @href | @conref | self::*[@id and not(@varid)]/@id"
             ishlinkxpath CDATA #FIXED "@conref | @href[contains(parent::*/@class,&apos; topic/image &apos;) and not(parent::*/@conref)]"
             spectitle  CDATA                            #IMPLIED
             %univ-atts;                                  
             outputclass 
                        CDATA                            #IMPLIED    >

<!ELEMENT cli_where       (#PCDATA | %basic.ph; | %simpletable; |
                           %note; | %txt.incl;)*                    >
<!ATTLIST cli_where  
             ishlabelxpath CDATA #FIXED "./title | @alt | @href | @conref | self::*[@id and not(@varid)]/@id"
             ishlinkxpath CDATA #FIXED "@conref | @href[contains(parent::*/@class,&apos; topic/image &apos;) and not(parent::*/@conref)]"
             %univ-atts;
             outputclass 
                        CDATA                            #IMPLIED    >

<!ELEMENT cli_where_head (%tblcell.cnt;)*                            >
<!ATTLIST cli_where_head
             ishlabelxpath CDATA #FIXED "./title | @alt | @href | @conref | self::*[@id and not(@varid)]/@id"
             ishlinkxpath CDATA #FIXED "@conref | @href[contains(parent::*/@class,&apos; topic/image &apos;) and not(parent::*/@conref)]"
             %univ-atts;
             outputclass 
                        CDATA                            #IMPLIED    >

<!ELEMENT cli_where_row  (%tblcell.cnt;)*                            >
<!ATTLIST cli_where_row
             ishlabelxpath CDATA #FIXED "./title | @alt | @href | @conref | self::*[@id and not(@varid)]/@id"
             ishlinkxpath CDATA #FIXED "@conref | @href[contains(parent::*/@class,&apos; topic/image &apos;) and not(parent::*/@conref)]"
             %univ-atts;
             outputclass 
                        CDATA                            #IMPLIED    >

<!-- ============================================================= -->
<!--                    SPECIALIZATION ATTRIBUTE DECLARATIONS      -->
<!-- ============================================================= -->
<!ATTLIST cli_reference     %global-atts;  class  CDATA "- topic/topic reference/reference cli_reference/cli_reference ">
<!ATTLIST cli_body         %global-atts;  class  CDATA "- topic/body reference/refbody cli_reference/cli_body ">
<!ATTLIST cli_syntax       %global-atts;  class  CDATA "- topic/section reference/refsyn cli_reference/cli_syntax ">
<!ATTLIST cli_prereq       %global-atts;  class  CDATA "- topic/section reference/section cli_reference/cli_prereq ">
<!ATTLIST cli_description  %global-atts;  class  CDATA "- topic/section reference/section cli_reference/cli_description ">
<!ATTLIST cli_postreq      %global-atts;  class  CDATA "- topic/section reference/section cli_reference/cli_postreq ">
<!ATTLIST cli_options      %global-atts;  class  CDATA "- topic/simpletable reference/properties cli_reference/cli_options ">
<!ATTLIST cli_args     %global-atts;  class  CDATA "- topic/simpletable reference/properties cli_reference/cli_args ">
<!ATTLIST cli_arg          %global-atts;  class  CDATA "- topic/strow reference/property cli_reference/cli_arg ">
<!ATTLIST cli_arg_value    %global-atts;  class  CDATA "- topic/stentry reference/propvalue cli_reference/cli_arg_value ">
<!ATTLIST cli_arg_desc     %global-atts;  class  CDATA "- topic/stentry reference/propvalue cli_reference/cli_arg_desc ">
<!ATTLIST cli_params       %global-atts;  class  CDATA "- topic/simpletable reference/properties cli_reference/cli_params ">
<!ATTLIST cli_options_head %global-atts;  class  CDATA "- topic/sthead reference/prophead cli_reference/cli_options_head ">
<!ATTLIST cli_option_type  %global-atts;  class  CDATA "- topic/stentry reference/proptypehd cli_reference/cli_option_type ">
<!ATTLIST cli_option       %global-atts;  class  CDATA "- topic/strow reference/property cli_reference/cli_option ">
<!ATTLIST cli_param        %global-atts;  class  CDATA "- topic/strow reference/property cli_reference/cli_param ">
<!ATTLIST cli_param_value  %global-atts;  class  CDATA "- topic/stentry reference/propvalue cli_reference/cli_param_value ">
<!ATTLIST cli_param_desc   %global-atts;  class  CDATA "- topic/stentry reference/propvalue cli_reference/cli_param_desc ">
<!ATTLIST cli_option_value %global-atts;  class  CDATA "- topic/stentry reference/propvalue cli_reference/cli_option_value ">
<!ATTLIST cli_option_desc  %global-atts;  class  CDATA "- topic/stentry reference/propdesc cli_reference/cli_option_desc ">
<!ATTLIST cli_backend_output %global-atts;  class  CDATA "- topic/section reference/section cli_reference/cli_backend_output ">
<!ATTLIST cli_example      %global-atts;  class  CDATA "- topic/example reference/example cli_reference/cli_example ">
<!ATTLIST cli_where        %global-atts;  class  CDATA "- topic/p reference/p cli_reference/cli_where ">
 
<!-- ================== End DITA EMC cli=========================== -->

