<?xml version="1.0" encoding="UTF-8"?>
<!-- ============================================================= -->
<!--                    HEADER                                     -->
<!-- ============================================================= -->
<!--  MODULE:    DITA Bookmap                                      -->
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
PUBLIC "-//OASIS//ELEMENTS DITA BookMap//EN" 
      Delivered as file "bookmap.mod"                              -->

<!-- ============================================================= -->
<!-- SYSTEM:     Darwin Information Typing Architecture (DITA)     -->
<!--                                                               -->
<!-- PURPOSE:    Define elements and specialization atttributes    -->
<!--             for Book Maps                                     -->
<!--                                                               -->
<!-- ORIGINAL CREATION DATE:                                       -->
<!--             March 2004                                        -->
<!--                                                               -->
<!--             (C) Copyright OASIS Open 2005, 2009.              -->
<!--             (C) Copyright IBM Corporation 2004, 2005.         -->
<!--             All Rights Reserved.                              -->
<!--  UPDATES:                                                     -->
<!--    2007.12.01 EK:  Reformatted DTD modules for DITA 1.2       -->
<!--    2008.01.28 RDA: Removed enumerations for attributes:       -->
<!--                    publishtype/@value, bookrestriction/@value -->
<!--    2008.01.28 RDA: Added <metadata> to <bookmeta>             -->
<!--    2008.01.30 RDA: Replace @conref defn. with %conref-atts;   -->
<!--    2008.02.01 RDA: Added keys attributes, more keyref attrs   -->
<!--    2008.02.12 RDA: Add keyword to many data specializations   -->
<!--    2008.02.12 RDA: Add @format, @scope, and @type to          -->
<!--                    publisherinformation                       -->
<!--    2008.02.13 RDA: Create .content and .attributes entities   -->
<!--    2008.03.17 RDA: Add appendices element                     -->
<!-- ============================================================= -->

<!-- ============================================================= -->
<!--                   ARCHITECTURE ENTITIES                       -->
<!-- ============================================================= -->

<!ENTITY bookmapRes-constraints "(topic bookmapRestrict-c)" >

<!ENTITY % term         "term">

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
<!--                   ELEMENT NAME ENTITIES                       -->
<!-- ============================================================= -->
 
<!ENTITY % bookmap         "bookmap"                                 >

<!ENTITY % abbrevlist      "abbrevlist"                              >
<!ENTITY % bookabstract    "bookabstract"                            >
<!ENTITY % appendices      "appendices"                              >
<!ENTITY % appendix        "appendix"                                >

<!ENTITY % backmatter      "backmatter"                              >
<!ENTITY % bibliolist      "bibliolist"                              >
<!ENTITY % bookchangehistory "bookchangehistory"                     >
<!ENTITY % bookevent       "bookevent"                               >
<!ENTITY % bookeventtype   "bookeventtype"                           >
<!ENTITY % bookid          "bookid"                                  >
<!ENTITY % booklibrary     "booklibrary"                             >
<!ENTITY % booklist        "booklist"                                >
<!ENTITY % booklists       "booklists"                               >
<!ENTITY % bookmeta        "bookmeta"                                >
<!ENTITY % booknumber      "booknumber"                              >
<!ENTITY % bookowner       "bookowner"                               >
<!ENTITY % bookpartno      "bookpartno"                              >
<!ENTITY % bookrestriction "bookrestriction"                         >
<!ENTITY % bookrights      "bookrights"                              >
<!ENTITY % booktitle       "booktitle"                               >
<!ENTITY % booktitlealt    "booktitlealt"                            >
<!ENTITY % chapter         "chapter"                                 >
<!ENTITY % colophon        "colophon"                                >
<!ENTITY % completed       "completed"                               >
<!ENTITY % copyrfirst      "copyrfirst"                              >
<!ENTITY % copyrlast       "copyrlast"                               >
<!ENTITY % day             "day"                                     >
<!ENTITY % dedication      "dedication"                              >
<!ENTITY % draftintro      "draftintro"                              >
<!ENTITY % edited          "edited"                                  >
<!ENTITY % edition         "edition"                                 >
<!ENTITY % figurelist      "figurelist"                              >
<!ENTITY % frontmatter     "frontmatter"                             >
<!ENTITY % glossarylist    "glossarylist"                            >
<!ENTITY % indexlist       "indexlist"                               >
<!ENTITY % isbn            "isbn"                                    >
<!ENTITY % mainbooktitle   "mainbooktitle"                           >
<!ENTITY % maintainer      "maintainer"                              >
<!ENTITY % month           "month"                                   >
<!ENTITY % notices         "notices"                                 >
<!ENTITY % organization    "organization"                            >
<!ENTITY % part            "part"                                    >
<!ENTITY % person          "person"                                  >
<!ENTITY % preface         "preface"                                 >
<!ENTITY % printlocation   "printlocation"                           >
<!ENTITY % published       "published"                               >
<!ENTITY % publisherinformation "publisherinformation"               >
<!ENTITY % publishtype     "publishtype"                             >
<!ENTITY % reviewed        "reviewed"                                >
<!ENTITY % revisionid      "revisionid"                              >
<!ENTITY % started         "started"                                 >
<!ENTITY % summary         "summary"                                 >
<!ENTITY % tablelist       "tablelist"                               >
<!ENTITY % tested          "tested"                                  >
<!ENTITY % trademarklist   "trademarklist"                           >
<!ENTITY % toc             "toc"                                     >
<!ENTITY % volume          "volume"                                  >
<!ENTITY % year            "year"                                    >
<!ENTITY % namedetails     "namedetails"                             >
<!ENTITY % emailaddresses  "emailaddresses"                          >
<!ENTITY % urls            "urls"                                    >
<!ENTITY % image           "image"                                   >
<!ENTITY % anchor      "anchor"                                      >
<!ENTITY % linktext    "linktext"                                    >
<!ENTITY % navref      "navref"                                      >
<!ENTITY % relcell     "relcell"                                     >
<!ENTITY % relcolspec  "relcolspec"                                  >
<!ENTITY % relheader   "relheader"                                   >
<!ENTITY % relrow      "relrow"                                      >
<!ENTITY % reltable    "reltable"                                    >
<!ENTITY % searchtitle "searchtitle"                                 >
<!ENTITY % shortdesc   "shortdesc"                                   >
<!ENTITY % topicmeta   "topicmeta"                                   >
<!ENTITY % topicref    "topicref"                                    >
<!ENTITY % fig          "fig"										 >
<!ENTITY % metadata     "metadata"                                   >
<!ENTITY % data  		   "data"                                    >
<!ENTITY % audience     "audience"                                   >
<!ENTITY % category     "category"                                   >
<!ENTITY % prodinfo     "prodinfo"                                   >
<!ENTITY % othermeta    "othermeta"                                  >
<!ENTITY % tm  		    "tm"   	                                     >
<!ENTITY % cite         "cite"                                       >
<!ENTITY % keyword       "keyword"                                   >
<!ENTITY % xref         "xref"                                       >
<!ENTITY % draft-comment 
                        "draft-comment"                              >
<!ENTITY % param        "param"                                      >
<!ENTITY % fn           "fn"                                         >
<!ENTITY % indexterm    "indexterm"                                  >
<!ENTITY % prodname     "prodname"                                   >
<!ENTITY % synph        "synph"                                      >
<!ENTITY % vrmlist      "vrmlist"                                    >
<!ENTITY % brand        "brand"                                      >
<!ENTITY % navtitle     "navtitle"                                   >
<!ENTITY % title        "title"                                      >
<!ENTITY % lines        "lines"                                      >
<!ENTITY % note         "note"										 >	
<!ENTITY % object       "object"                                     >
<!ENTITY % ol           "ol"                                         >
<!ENTITY % ul           "ul"                                         >
<!ENTITY % p            "p"                                          >
<!ENTITY % simpletable  "simpletable"                                >
<!ENTITY % codeph       "codeph"                                     >
<!ENTITY % option       "option"                                     >
<!ENTITY % parmname     "parmname"                                   >
<!ENTITY % text         "text"                                       >
<!ENTITY % parml        "parml"                                      >
<!ENTITY % indexterm    "indexterm"                                  >

<!ENTITY % desc        "desc"                                      >
<!ENTITY % table  "table"                                  >
<!ENTITY % keywords     "keywords"			>
<!-- ============================================================= -->
<!--                    DOMAINS ATTRIBUTE OVERRIDE                 -->
<!-- ============================================================= -->

<!ENTITY % pre          "
						 %sw-d-pre;|
                         %pr-d-pre;
                        ">

<!ENTITY % ph           "ph | 
                         %hi-d-ph; | 
                         %pr-d-ph; | 
                         %sw-d-ph; | 
                         %ui-d-ph;
                        ">

<!ENTITY % dl           "dl |
                         %pr-d-dl;
                        ">						
						
<!ENTITY included-domains 
  ""
>

<!ENTITY % data.elements.incl 
  "%data;"
>

<!ENTITY % words.cnt 
  "#PCDATA | 
   %data.elements.incl; | 
   %keyword; | 
   %term;
  "
>


<!ENTITY % txt.incl 
  "%draft-comment; |
   
   %indexterm;
  ">

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

<!ENTITY % basic.ph 
 
   "%cite; | 
   %keyword; | 
   %ph; | 
 
   %term; | 
   %tm; | 
   %xref;
  "
>

<!ENTITY % basic.phandblock 
  "%basic.block; | 
   %basic.ph;
  " 
>
  
  <!ENTITY % listitem.cnt 
  "#PCDATA | 
   %basic.block; |
   %basic.ph; | 
   %data.elements.incl; | 
   
   
   %txt.incl;
  "
>

<!ENTITY % draft-comment.content
                       "(#PCDATA | 
                         %basic.phandblock; | 
                         %data.elements.incl; )*"
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

<!ENTITY % note.cnt 
  "#PCDATA | 
   %basic.block.nonote; | 
   %basic.ph; | 
   %data.elements.incl; | 
   
   %txt.incl;
  "
>

  

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



<!ENTITY % term.cnt 
  "#PCDATA | 
   %basic.ph; | 
   %data.elements.incl; | 
 
   %image;
  "
>

 <!ENTITY % fig.content
                       "((%title;)?, 
                         (%desc;)?, 
                         (
                          %fig.cnt;)* )"
>
 
<!ENTITY % pre.cnt 
  "#PCDATA | 
   %basic.ph; | 
   %data.elements.incl; | 
 
   %txt.incl;
  "
>

<!ENTITY % basic.ph.notm
   "%cite; | 
   %keyword; | 
   %ph; | 
   
   %term; | 
   %xref;
  "
>

 <!ENTITY % codeph.content
                       "(#PCDATA | 
                         %basic.ph.notm; | 
                         %data.elements.incl;)*"
> 


<!ENTITY % synph.content
                       "(#PCDATA | 
                         %codeph; | 
                         
                         
                         
                         %option; | 
                         %parmname; |
                         
                         %synph; |
                         %text;
                         )*
">
 
<!ENTITY % basic.ph.notm
   "%cite; | 
   %keyword; | 
   %ph; | 
   
   %term; | 
   %xref;
  "
>

<!ENTITY % data.elements.incl 
  "%data;
  "
>

<!ENTITY % basic.ph.noxref
  "
   %keyword; | 
   %ph; | 
   
   %term; | 
   %tm;
   
  "
>

<!ENTITY % xreftext.cnt 
  "#PCDATA | 
   %basic.ph.noxref; | 
   %data.elements.incl; | 
    
   %image;
  "
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


<!ENTITY % xrefph.cnt 
  "#PCDATA | 
   %basic.ph.noxref; | 
   %data.elements.incl; 
 
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

<!ENTITY % ph.cnt 
  "#PCDATA | 
   %basic.ph; | 
   %data.elements.incl; | 
   
   %image; | 
   %txt.incl;
  "
>

<!ENTITY % txt.incl 
  "%draft-comment; |
   
   %indexterm;
  ">
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

<!ENTITY % tblcell.cnt 
  "#PCDATA | 
   %basic.block.notbl; | 
   %basic.ph; | 
   %data.elements.incl; | 
 
   %txt.incl;
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


<!ENTITY % para.cnt 
  "#PCDATA | 
   %basic.block.nopara; | 
   %basic.ph; | 
   %data.elements.incl; | 
   
   %txt.incl;
  "
>


<!ENTITY % title.cnt 
  "#PCDATA | 
   %basic.ph.noxref; | 
   %data.elements.incl; | 
   
   %image;
  "
>

<!ENTITY % topichead.content
                       "((%topicmeta;)?, 
                         (%data.elements.incl; | 
                          %navref; | 
                          %topicref;)* )"
>
<!--                    LONG NAME: Book Metadata                   -->

<!ENTITY % publisherinformation.content
                       "((
                          (%organization;))*, 
                         
                          
                         (%data;)*)"
>

<!ENTITY % bookmeta.content
                       "((%linktext;)?, 
                         (%searchtitle;)?, 
                         (%shortdesc;)?, 
                         
                          
                         
                         
                          
                         (%metadata;)*, 
                         (%audience;)*, 
                         (%category;)*, 
                         (%keywords;)*, 
                         (%prodinfo;)*, 
                         (%othermeta;)*, 
                          
                         (%bookid;)?,
                         
                         (%bookrights;)*,
                         (%data;)*)"
>


<!ENTITY % mapgroup-d-topicref 
  "keydef |
   mapref |
   topicgroup |
   topichead | 
   topicset |
   topicsetref
  "                     
>

<!ENTITY % desc.cnt 
  "#PCDATA | 
   %basic.block.notbfgobj; | 
   %basic.ph; | 
   %data.elements.incl;
  "
>

<!ENTITY % object.content
                       "((%desc;)?,
                         
                         (%param;)*
                         )"
>

<!--                    LONG NAME: Back Matter                     -->
<!ENTITY % backmatter.content
                       "(%booklists; | 
                         %colophon; | 
                         
                         %notices; | 
                         %topicref;)*"
>
<!--                    LONG NAME: Book Change History             -->
<!ENTITY % bookchangehistory.content
                       "( 
                          
                          
                         (%bookevent;)*)"
>
<!--                    LONG NAME: Library Title                   -->
<!ENTITY % booklibrary.content
                       "(#PCDATA | 
                          
                         %image;)*"
>
<!--                    LONG NAME: Main Book Title                 -->
<!ENTITY % mainbooktitle.content
                       "(#PCDATA | 
                         %basic.ph.noxref; | 
                         %image;)*"
>

<!ENTITY % basic.ph.noxref
  " 
   %keyword; | 
   %ph; | 
   
   %term; | 
   %tm; 
  "
>

<!--                    LONG NAME: Alternate Book Title            -->
<!ENTITY % booktitlealt.content
                       "(#PCDATA | 
                         
                         %image;)*"
>

<!--                    LONG NAME: Book Lists                      -->
<!ENTITY % booklists.content
                       "(
                         
                         (%booklist;) |
                         
                         (%glossarylist;) |
                         (%indexlist;) |
                         
                         
                         (%toc;))*"
>

<!ENTITY % codeblock.content
                       "(#PCDATA | 
                         %basic.ph.notm;  |
                         %data.elements.incl; | 
                         
                         %txt.incl;)* 
 ">
 
 
 
 <!ENTITY % frontmatter.content
                       "(%bookabstract; | 
                         %booklists; | 
                         
                         
                         
                         %notices; | 
                         %preface; | 
                         %topicref;)*"
>

<!ENTITY % published.content
                       "((
                          (%organization;))*,
                          
                         
                         
                          
                         
                         (%data;)*)"
>

<!ENTITY % reviewed.content
                       "(((%organization;) )*, 
                         
                         
                         
                          
                         (%data;)*)"
>

<!ENTITY % edited.content
                       "(((%organization;))*, 
                          
                          
                           
                          
                          (%data;)*)"
>

<!ENTITY % tested.content
                       "(((%organization;))*, 
                          
                          
                          
                          
                          (%data;)*)"
>

<!ENTITY % prodinfo.content
                       "((%prodname;), 
                         (%vrmlist;),
                         (%brand;)* )"
>


<!ENTITY % bookrights.content
                       "((%copyrfirst;)?, 
                        
                         (%bookowner;), 
                         (%bookrestriction;)?)"
>

<!ENTITY % completed.content
                       "(%year;)"
>

<!ENTITY % started.content
                       "(%year;)"
>

<!ENTITY % bookid.content
                       "((%bookpartno;)*, 
                         
                         
                         (%booknumber;)?, 
                         (%volume;)*, 
                         (%maintainer;)?)"
>

<!ENTITY % fig          "fig">

<!ENTITY % note         "note 
                        ">						

<!ENTITY % indexing-d-index-base 
  "index-see | 
   index-see-also
  "
>						

<!ENTITY % pr-d-ph      
  "codeph
  "
>

<!ENTITY % pre          "pre | 
                         %pr-d-pre; 
                        ">

<!ENTITY % sw-d-ph      
  "filepath | 
  
    
   userinput
  "
>

<!ENTITY % uicontrol.content
                       "(%words.cnt; | 
                         %image;
                         )*"
>

<!ENTITY % topicmeta.content
                       "((%navtitle;)?,
                         (%linktext;)?, 
                         (%searchtitle;)?, 
                         (%shortdesc;)?, 
                          
                         
                         
                         
                         
                         
                         (%metadata;)*, 
                         (%audience;)*, 
                         (%category;)*, 
                         (%keywords;)*, 
                         (%prodinfo;)*, 
                         (%othermeta;)*, 
                         
                         (%data.elements.incl;)*)">

						 
<!ENTITY % topicref.content
                       "((%topicmeta;)?, 
                         (
                          %data.elements.incl; |
                          %navref; | 
                          %topicref;)* )"
>						 

<!-- ================== End book map ============================= -->