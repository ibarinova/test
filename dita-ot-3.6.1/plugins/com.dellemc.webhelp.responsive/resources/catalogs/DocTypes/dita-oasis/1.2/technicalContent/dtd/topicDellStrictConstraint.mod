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

<!ENTITY topic-constraints "(topic topicDellTopic-c)" >

<!ENTITY % term         "term">
<!ENTITY % conbody     "conbody"                                     >
<!ENTITY % title   		"title"     >
<!ENTITY % titlealts     "titlealts"                                     >
<!ENTITY % abstract  "abstract"                                  >
<!ENTITY % shortdesc      "shortdesc"                                      >
<!ENTITY % prolog      "prolog"                                      >
<!ENTITY % refbody      "refbody"                                      >
<!ENTITY % body         "body"                                       >
<!ENTITY % related-links      "related-links"                                      >
<!ENTITY % shortdesc      "shortdesc"                                      >
<!ENTITY % desc      "desc"                                      >
<!ENTITY % image        "image"                                      >
<!ENTITY % simpletable  "simpletable"                                >
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
<!ENTITY % codeph       "codeph"                                     >
<!ENTITY % option       "option"                                     >
<!ENTITY % parmname     "parmname"                                   >
<!ENTITY % synph        "synph"                                      >
<!ENTITY % text         "text"                                       >
<!ENTITY % parml        "parml"                                      >
<!ENTITY % indexterm    "indexterm"                                  >
<!ENTITY % cite         "cite"                                       >
<!ENTITY % q            "q"                                          >
<!ENTITY % xref         "xref"                                       >
<!ENTITY % audience     "audience"                                   >
<!ENTITY % category     "category"                                   >
<!ENTITY % keywords     "keywords"									>
<!ENTITY % prodinfo     "prodinfo"                                   >
<!ENTITY % sectiondiv  "sectiondiv"                                  >
<!ENTITY % note         "note"										 >	
<!ENTITY % draft-comment 
                        "draft-comment"                              >

<!ENTITY % topic-info-types 
                        "topic"                                    >						
						
<!ENTITY % data.elements.incl 
  "%data;
  "
>


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
						
<!ENTITY % prodinfo.content
                       "((%prodname;), 
                         (%vrmlist;),
                         (%brand;)* )"
>

<!ENTITY % data.elements.incl 
  "%data;
  "
>

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

<!ENTITY % body.cnt 
  "%basic.block; | 
   %data.elements.incl; |
   %draft-comment; 
  "
>

<!ENTITY % txt.incl 
  "%draft-comment; |
   
   %indexterm;
  ">


<!ENTITY % bodydiv.cnt 
  "#PCDATA | 
   %basic.block; | 
   %basic.ph; | 
   %data.elements.incl; | 

   %txt.incl;
  ">

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


<!ENTITY % fn           "fn"                                         >


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

<!ENTITY % sectiondiv.cnt 
  "#PCDATA | 
   %basic.block; | 
   %basic.ph; | 
   %data.elements.incl; | 
   
   %txt.incl;
  "
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

<!ENTITY % section.content
                       "(%section.cnt;)*"
>

<!ENTITY % topic.content
                       "((%title;), 
                         (%titlealts;)?,
                         (%shortdesc;)?, 
                         (%prolog;)?, 
                         (%body;)?, 
                         (%related-links;)?,
                         (%topic-info-types;)*)
">