# Curtle
Leaning Bot using Lex &amp; Yacc 
Documentation contains details about implementations and some results.
Non-relational database
  o File ‘knowledge.xml’ is a non-relational database which contains information about mathematical terms
  o Teaching – knowledge
    <about> tag is for item’s name (like: prime, odd)
    <definition> is for definition and examples
  o Test – questions and answers
    <question> tag is for the question
    <correct> holds the correct answer

XML2C.c
   o Contains operation for extracting data from ‘knowledge.xml’ where are kept definitions and terms to be presented
   o There are four structures used: two for keeping data for each new learning item, and two for test data:
