<?xml version="1.0" encoding="UTF-8"?>
<!-- ============================================================= -->
<!--                    HEADER                                     -->
<!-- ============================================================= -->
<!--  MODULE:    DITA Reference                                    -->
<!--  VERSION:   1.2                                               -->
<!--  DATE:      November 2009                                     -->
<!--                                                               -->
<!-- ============================================================= -->

<!-- ============================================================= -->
<!--                    PUBLIC DOCUMENT TYPE DEFINITION            -->
<!--                    TYPICAL INVOCATION                         -->
<!--                                                               -->
<!--  Refer to this file by the following public identifier or an 
      appropriate system identifier 
PUBLIC "-//OASIS//ELEMENTS DITA Reference//EN"
      Delivered as file "reference.mod"                            -->

<!-- ============================================================= -->
<!-- SYSTEM:     Darwin Information Typing Architecture (DITA)     -->
<!--                                                               -->
<!-- PURPOSE:    Declaring the elements and specialization         -->
<!--             attributes for Reference                          -->
<!--                                                               -->
<!-- ORIGINAL CREATION DATE:                                       -->
<!--             March 2001                                        -->
<!--                                                               -->
<!--             (C) Copyright OASIS Open 2005, 2009.              -->
<!--             (C) Copyright IBM Corporation 2001, 2004.         -->
<!--             All Rights Reserved.                              -->
<!--                                                               -->
<!--  UPDATES:                                                     -->
<!--    2005.11.15 RDA: Removed old declaration for                -->
<!--                    referenceClasses entity                    -->
<!--    2005.11.15 RDA: Corrected LONG NAME for propdeschd         -->
<!--    2006.06.07 RDA: Added <abstract> element                   -->
<!--    2006.06.07 RDA: Make universal attributes universal        -->
<!--                      (DITA 1.1 proposal #12)                  -->
<!--    2006.11.30 RDA: Remove #FIXED from DITAArchVersion         -->
<!--    2007.12.01 EK:  Reformatted DTD modules for DITA 1.2       -->
<!--    2008.01.30 RDA: Replace @conref defn. with %conref-atts;   -->
<!--    2008.02.13 RDA: Create .content and .attributes entities   -->
<!--    2008.05.06 RDA: Added refbodydiv                           -->
<!-- ============================================================= -->


<!-- ============================================================= -->
<!--                   ARCHITECTURE ENTITIES                       -->
<!-- ============================================================= -->
<!ENTITY apos "'">

<!ENTITY task-constraints "(topic taskOnlyTopic-c)" >

<!ENTITY % term         "term">

<!ENTITY % title   		"title"     >
<!ENTITY % titlealts     "titlealts"                                     >
<!ENTITY % abstract  "abstract"                                  >
<!ENTITY % shortdesc      "shortdesc"                                      >
<!ENTITY % prolog      "prolog"                                      >
<!ENTITY % refbody      "refbody"                                      >
<!ENTITY % related-links      "related-links"                                      >
<!ENTITY % shortdesc      "shortdesc"                                      >
<!ENTITY % desc      "desc"                                      >
<!ENTITY % image        "image"                                      >
<!ENTITY % lines        "lines"                                      >
<!ENTITY % object       "object"                                     >
<!ENTITY % ol           "ol"                                         >
<!ENTITY % p            "p"                                          >
<!ENTITY % ul           "ul"                                         >
<!ENTITY % example      "example"                                    >
  <!ENTITY % section  "section"                                  >
 <!ENTITY % data  		 "data"                                  >
 <!ENTITY % tm  		 "tm"		                                  >
 <!ENTITY % metadata     "metadata"                                   >
 <!ENTITY % alt          "alt"                                        >
 <!ENTITY % param        "param"                                      >
 <!ENTITY % table  "table"                                  >
<!ENTITY % prodname     "prodname"                                   >
<!ENTITY % vrmlist      "vrmlist"                                    >
<!ENTITY % brand        "brand"                                      >
<!ENTITY % othermeta    "othermeta"                                  >
<!ENTITY % sectiondiv  "sectiondiv"                                  >
<!ENTITY % codeph       "codeph"                                     >
<!ENTITY % option       "option"                                     >
<!ENTITY % parmname     "parmname"                                   >
<!ENTITY % synph        "synph"                                      >
<!ENTITY % text         "text"                                       >
<!ENTITY % parml        "parml"                                      >
<!ENTITY % indexterm    "indexterm"                                  >
<!ENTITY % simpletable  "simpletable"                                >
<!ENTITY % note         "note"										 >	
<!ENTITY % cite         "cite"                                       >
<!ENTITY % q            "q"                                          >
<!ENTITY % prereq          "prereq">
<!ENTITY % context         "context">
<!ENTITY % steps           "steps">
<!ENTITY % steps-unordered "steps-unordered">
<!ENTITY % result          "result">
<!ENTITY % example         "example">
<!ENTITY % postreq         "postreq">
<!ENTITY % taskbody    "taskbody"                                    >
<!ENTITY % xref         "xref"                                       >
<!ENTITY % audience     "audience"                                   >
<!ENTITY % category     "category"                                   >
<!ENTITY % keywords     "keywords"									>
<!ENTITY % prodinfo     "prodinfo"                                   >
<!ENTITY % choices     "choices"                                     >
<!ENTITY % task        "task"                                        >
<!ENTITY % taskbody    "taskbody"                                    >
<!ENTITY % steps       "steps"                                       >
<!ENTITY % steps-unordered 
                       "steps-unordered"                             >
<!ENTITY % step        "step"                                        >
<!ENTITY % stepsection "stepsection"                                 >
<!ENTITY % cmd         "cmd"                                         >
<!ENTITY % substeps    "substeps"                                    >
<!ENTITY % substep     "substep"                                     >
<!ENTITY % tutorialinfo 
                       "tutorialinfo"                                >
<!ENTITY % info        "info"                                        >
<!ENTITY % stepxmp     "stepxmp"                                     >
<!ENTITY % stepresult  "stepresult"                                  >
<!ENTITY % choices     "choices"                                     >
<!ENTITY % choice      "choice"                                      >
<!ENTITY % steps-informal "steps-informal"                           >
<!ENTITY % result      "result"                                      >
<!ENTITY % prereq      "prereq"                                      >
<!ENTITY % postreq     "postreq"                                     >
<!ENTITY % context     "context"                                     >
<!ENTITY % choicetable "choicetable"                                 >
<!ENTITY % chhead      "chhead"                                      >
<!ENTITY % chrow       "chrow"                                       >
<!ENTITY % choptionhd  "choptionhd"                                  >
<!ENTITY % chdeschd    "chdeschd"                                    >
<!ENTITY % choption    "choption"                                    >
<!ENTITY % chdesc      "chdesc"                                      >

<!ENTITY % draft-comment 
                        "draft-comment"                              >
						
 <!ENTITY % pre          "
						 %sw-d-pre;|
                         %pr-d-pre;
                        ">
<!ENTITY % pr-d-dl      
  "parml
  "                                      
>						
<!ENTITY % dl           "dl |
                         %pr-d-dl;
                        ">
				
<!ENTITY % keyword      "keyword |
                         %pr-d-keyword; | 
                         %sw-d-keyword; |
                         %ui-d-keyword;
                        ">						
<!ENTITY % sw-d-ph      
  "filepath | 
   msgph |
     userinput
  "
>

<!ENTITY % taskbody.content
                       "(((%prereq;) | 
                          (%context;) |
                          (%section;))*,
                         ((%steps; | 
                           %steps-unordered;))?, 
                         (%result;)?, 
                         (%example;)*, 
                         (%postreq;)*)"
>
						
<!ENTITY % prodinfo.content
                       "((%prodname;), 
                         (%vrmlist;),
                         (%brand;)* )"
>

<!ENTITY % data.elements.incl 
  "%data;
  "
>

<!ENTITY % txt.incl 
  "%draft-comment; |
   
   %indexterm;
  ">

<!ENTITY % hi-d-ph      
  "b | 
   i | 
   sup | 
   sub |
   tt | 
   u 
  "
>

<!ENTITY % ph           "ph |
                         %hi-d-ph; |
                         %pr-d-ph; |
                         %sw-d-ph; | 
                         %ui-d-ph;
                        ">

<!ENTITY % ph           "ph | 
                         %hi-d-ph;
                        ">

<!ENTITY % fig          "fig">

<!ENTITY % basic.block 
  "%dl; | 
   %fig; | 
   %image; | 
   %lines; | 
 
   %note; | 
   %object; | 
   %ol;| 
   %p; | 
 %pre; |
 %simpletable; | 
   %table; | 
   %ul;
  "
>

<!ENTITY % basic.block.notbl
  "%dl; | 
   %fig; | 
   %image; | 
   %lines; | 
   
   %note; | 
   %object; | 
   %ol;| 
   %p; | 
    
   
   %ul;
  "
>

<!ENTITY % basic.block.nonote
  "%dl; | 
   %fig; | 
   %image; | 
   %lines; | 
 
   %object; | 
   %ol;| 
   %p; | 
    
  
    %pre; | 
   %simpletable; |
   %table; | 
   %ul;
  "
>
<!ENTITY % basic.block.nopara
  "%dl; | 
   %fig; | 
   %image; | 
   %lines; | 
 
   %note; | 
   %object; | 
   %ol;| 
    
	%pre; | 
   %simpletable; |   
   
   %table; | 
   %ul;
  "
>




<!ENTITY % basic.ph 
 
   "%cite; | 
   %keyword; | 
   %ph; | 
   %q; |
   %term; | 
   %tm; | 
   %xref;
  "
>



<!ENTITY % basic.ph.noxref
  "
   %keyword; | 
   %ph; | 
   %q; |
   %term; | 
   %tm;
   
  "
>

<!ENTITY % title.cnt 
  "#PCDATA | 
   %basic.ph.noxref; | 
   %data.elements.incl; | 
 
   %image;
  "
>


<!ENTITY % term.cnt 
  "#PCDATA | 
   %basic.ph; | 
   %data.elements.incl; | 
 
   %image;
  "
>


<!ENTITY % words.cnt 
  "#PCDATA | 
   %data.elements.incl; | 
   %keyword; | 
   %term;
  "
>


<!ENTITY % xrefph.cnt 
  "#PCDATA | 
   %basic.ph.noxref; | 
   %data.elements.incl; 
 
  "
>

<!ENTITY % data.elements.incl 
  "%data;"
>

<!ENTITY % basic.ph.notm
   "%cite; | 
   %keyword; | 
   %ph; | 
   %q; |
   %term; | 
   %xref;
  "
>

<!ENTITY % draft-comment 
                        "draft-comment"                              >
<!ENTITY % fn           "fn"                                         >

<!ENTITY % task-info-types 
                        "task"                                       >

<!ENTITY % task.content
                       "((%title;), 
                         (%titlealts;)?,
                         (
                          %shortdesc;)?, 
                         (%prolog;)?, 
                         (%taskbody;)?, 
                         (%related-links;)?, 
                         (%task-info-types;)* )"
>

<!ENTITY % section.notitle.cnt 
  "#PCDATA | 
   %basic.block; | 
   %basic.ph; | 
   %data.elements.incl; | 
 
   %sectiondiv; | 
   %txt.incl;
  "
>

<!ENTITY % sectiondiv.cnt 
  "#PCDATA | 
   %basic.block; | 
   %basic.ph; | 
   %data.elements.incl; | 
   
   %txt.incl;
  "
>

<!ENTITY % txt.incl 
  "%draft-comment; |
   
   %indexterm;
  ">

 <!ENTITY % codeph.content
                       "(#PCDATA | 
                         %basic.ph.notm; | 
                         %data.elements.incl;)*"
> 
  
  
<!ENTITY % codeblock.content
                       "(#PCDATA | 
                         %basic.ph.notm;  |
                         
                         %data.elements.incl; | 
                         
                         %txt.incl;)* 
 ">

<!ENTITY % image.content
                       "((%alt;)?
                         )
">
 
 <!ENTITY % basic.block.notbnofg
  "%dl; | 
   %image; | 
   %lines; | 
 
   %note; | 
   %object; | 
   %ol;| 
   %p; | 
    
    
   %ul;
  "
>

<!ENTITY % basic.block.notbfgobj
  "%dl; | 
   %image; | 
   %lines; | 
   
   %note; | 
   %ol;| 
   %p; | 
    
   
   %ul;
  "
>

 
 <!ENTITY % fig.cnt 
  "%basic.block.notbnofg; | 
   %data.elements.incl; |
   %simpletable; |    
   %xref;
  "
>
 
 <!ENTITY % fig.content
                       "((%title;)?, 
                         (%desc;)?, 
                         (
                          %fig.cnt;)* )"
>


<!ENTITY % indexing-d-index-base 
  "index-see | 
   index-see-also
  "
>
<!ENTITY % index-base   "%indexing-d-index-base;">

<!ENTITY % indexterm.content
                       "(%words.cnt;|
                         %indexterm;|
                         %index-base;)*"
>						



<!ENTITY % listitem.cnt 
  "#PCDATA | 
   %basic.block; |
   %basic.ph; | 
   %data.elements.incl; | 
   
   
   %txt.incl;
  "
>

<!ENTITY % object.content
                       "((%desc;)?,
                         
                         (%param;)*
                         )"
>

<!--                    LONG NAME: Syntax Phrase                   -->
<!ENTITY % synph.content
                       "(#PCDATA | 
                         %codeph; | 
                         
                         
                         
                         %option; | 
                         %parmname; |
                         
                         %synph; |
                         %text;
                         )*
">



<!ENTITY % sw-d-ph      
  "filepath | 
  msgph |
   
   userinput
  "
>

<!ENTITY % prolog.content
                       "( 
                         
                         
                         
                         (%metadata;)*, 
                         
                         (%data.elements.incl;)*)"
>

<!ENTITY % uicontrol.content
                       "(%words.cnt; | 
                         %image;
                         )*"
>

<!ENTITY % example.cnt 
  "#PCDATA | 
   %basic.block; | 
   %basic.ph; | 
   %data.elements.incl; | 
  %title; | 
   %txt.incl;
  "
>

<!ENTITY % tblcell.cnt 
  "#PCDATA | 
   %basic.block.notbl; | 
   %basic.ph; | 
   %data.elements.incl; | 
 
   %txt.incl;
  "
>

<!ENTITY % pre.cnt 
  "#PCDATA | 
   %basic.ph; | 
   %data.elements.incl; | 
 
   %txt.incl;
  "
>

<!ENTITY % defn.cnt 
  "#PCDATA | 
   %basic.block; |
   %basic.ph; | 
   %data.elements.incl; | 
 
   
   %txt.incl;
  "
>

<!ENTITY % itemgroup.cnt 
  "#PCDATA | 
   %basic.block; | 
   %basic.ph; | 
   %data.elements.incl; | 
   
   %txt.incl;
  "
>

<!ENTITY % desc.cnt 
  "#PCDATA | 
   %basic.block.notbfgobj; | 
   %basic.ph; | 
   %data.elements.incl; 
  "
>

<!ENTITY % codeph.content
                       "(#PCDATA | 
                         %basic.ph.notm; | 
                         %data.elements.incl;)*"
>

<!ENTITY % u.content
                       "(#PCDATA | 
                         %basic.ph; | 
                         %data.elements.incl;)*"
>

<!ENTITY % tt.content
                       "(#PCDATA | 
                         %basic.ph; | 
                         %data.elements.incl;)*"
>

<!ENTITY % sub.content
                       "(#PCDATA | 
                         %basic.ph; | 
                         %data.elements.incl;)*"
>

<!ENTITY % sup.content
                       "(#PCDATA | 
                         %basic.ph; | 
                         %data.elements.incl;)*"
>

<!ENTITY % i.content
                       "(#PCDATA | 
                         %basic.ph; | 
                         %data.elements.incl;)*"
>

<!ENTITY % b.content
                       "(#PCDATA | 
                         %basic.ph; | 
                         %data.elements.incl;)*"
>

<!ENTITY % ph.cnt 
  "#PCDATA | 
   %basic.ph; | 
   %data.elements.incl; | 
   
   %image; | 
   %txt.incl;
  "
>

<!ENTITY % xreftext.cnt 
  "#PCDATA | 
   %basic.ph.noxref; | 
   %data.elements.incl; | 
    
   %image;
  "
>

<!ENTITY % para.cnt 
  "#PCDATA | 
   %basic.block.nopara; | 
   %basic.ph; | 
   %data.elements.incl; | 
   
   %txt.incl;
  "
>

<!ENTITY % note.cnt 
  "#PCDATA | 
   %basic.block.nonote; | 
   %basic.ph; | 
   %data.elements.incl; | 
   
   %txt.incl;
  "
>

<!ENTITY % basic.phandblock 
  "%basic.block; | 
   %basic.ph;
  " 
>

<!ENTITY % metadata.content
                       "((%audience;)*, 
                         (%category;)*, 
                         (%keywords;)*,
                         (%prodinfo;)*, 
                         (%othermeta;)*, 
                         (%data.elements.incl;)*)"
>

<!ENTITY % draft-comment.content
                       "(#PCDATA | 
                         %basic.phandblock; | 
                         %data.elements.incl; )*"
>

<!ENTITY % step.content
                       "((%note;)*,
                         %cmd;, 
                         (%choices; |
                          %choicetable; | 
                          %info; |
                          %stepxmp; | 
                          %substeps;)*, 
                         (%stepresult;)? )"
>

<!ENTITY % substep.content
                       "((%note;)*,
                         %cmd;, 
                         (%info;|
                          %stepxmp;)*, 
                         (%stepresult;)? )"
>

<!ENTITY % section.cnt 
  "#PCDATA | 
   %basic.block; | 
   %basic.ph; | 
   %data.elements.incl; | 
   
   %sectiondiv; | 
   %title; | 
   %txt.incl;
  "
>

