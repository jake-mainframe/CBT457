//LIFE    JOB (SYS),'INSTALL LIFE',CLASS=A,MSGCLASS=A,COND=(1,LT),
//        USER=IBMUSER,PASSWORD=SYS1
//* From CBT Tape 134
// EXEC ASMFCL,MAC='SYS1.AMODGEN',MAC1='SYS1.MACLIB',
//             PARM.ASM='LIST,XREF,OBJECT,NODECK',
//             PARM.LKED='XREF,LET,LIST,NCAL'
//ASM.SYSIN DD *
         PRINT NOGEN
LIFE     START 0
LIFE     CSECT
         BC    15,14(0,15)
         DC    X'08'
         DC    CL8'LIFE    '
         DS    0H
         STM   14,12,12(13)        SAVE REGISTERS
         BALR  12,0
         USING *,12,10             ESTABLISH CSECT BASE REGISTER
         LA    10,4095(,12)
         LA    10,1(,10)
         ST    13,SAVE+4
         LR    2,13
         LA    13,SAVE             ESTABLISH LOCAL SAVE AREA
         ST    13,8(0,2)
R0       EQU   0
R1       EQU   1
R2       EQU   2
R3       EQU   3
R4       EQU   4
R5       EQU   5
R6       EQU   6
R7       EQU   7
R8       EQU   8
R9       EQU   9
R10      EQU   10
R11      EQU   11
R12      EQU   12
R13      EQU   13
R14      EQU   14
R15      EQU   15
         TM    0(R1),X'80'     IS IT INVOKED AS A CMND PROCESSOR?
         BO    ERROR1          NO, FLEE
         LR    R8,R1           RESTORE PARM ADDRESS
GETSIZE  GTSIZE ,              WHAT IS THE SCREENSIZE?
         CH    R0,=H'0'
         BNH   ERROR8          EXTRICATE THYSELF IF THINE VIDEO ISN'T
         ST    R1,WIDTH        WIDTH
         ST    R0,DEPTH        DEPTH
         AH    R0,=H'2'        AN EXTRA ROW EITHER WAY FOR OVERFLOW
         LR    R2,R0
         SR    R0,R0
         MR    R0,R2           MULTIPLY FOR TOTAL #BYTES NEEDED
         LR    R2,R1           SAVE FOR LATER
         S     R2,WIDTH        LESS THE TWO ROWS ABOVE....
         S     R2,WIDTH
         AH    R2,=H'3'        PLUS CURSOR POSITION INFO GIVES....
         ST    R2,LENGTHG      TOTAL LENGTH OF SCREEN RETRIEVE
         AH    R2,=H'2'        AND 5 BYTE PREFIX FOR TPUT GIVES...
         ST    R2,LENGTH       TOTAL LENGTH OF SCREEN DISPLAY
         LA    R2,1(,R2)
         ST    R2,LENGTH3
         BCTR  R2,R0
         AH    R1,=H'2'        AN EXTRA TWO BYTES FOR CONVENIENCE!!!
         ST    R1,STORAGE      TOTAL NUMBER OF BYTES FOR THE DISPLAY
         GETMAIN  R,LV=(1)
         ST    R1,ADDRESS      SAVE OUR START ADDRESS
         LA    R4,BLNKS        NOW CLEAR GETMAINED STORAGE....
         LR    R2,R1
         L     R3,STORAGE
         L     R5,PADDING
         MVCL  R2,R4           FILL GETMAINED AREA WITH PAD OF BLANK
         A     R1,STORAGE      CALCULATE END OF SCREEN WITHIN STORAGE
         S     R1,WIDTH        MINUS EXTRA ROW.....
         SH    R1,=H'1'        LESS THE CONVENIENCE BYTE GIVES....
         ST    R1,LIMIT        VERACIOUS ENDING
         L     R1,WIDTH        WIDTH
         L     R0,DEPTH        DEPTH
         AH    R1,=H'2'        AN EXTRA TWO COLUMNS FOR ATTR BYTES
         AH    R0,=H'2'        AN EXTRA TWO ROWS
         LR    R2,R0
         SR    R0,R0
         MR    R0,R2           MULTIPLY FOR TOTAL #BYTES NEEDED
         ST    R1,STORAGE2     SAVE FOR LATER
         S     R1,WIDTH
         S     R1,WIDTH
         SH    R1,=H'4'        2 FOR EACH WIDTH
         AH    R1,=H'8'        PREFIX
         SH    R1,=H'2'        FOR THE TITLE LINE
         ST    R1,LENGTH2
         L     R2,ATTNA2
         STAX  ATT2,MF=(E,(R2))
         L     R2,ATTNA
         STAX  ATTN,MF=(E,(R2)),REPLACE=NO
         USING CPPL,R8         ESTABLISH ADDRESSABILITY
         MVC   PPLCBUF,CPPLCBUF
         MVC   PPLUPT,CPPLUPT
         MVC   PPLECT,CPPLECT
         CALLTSSR EP=IKJPARS,MF=(E,PPL)
         LTR   R15,R15         WAS PARSE SUCCESSFUL?
         BNZ   ERROR2          NO, ERROR
         MVI   FLAGERRF,X'01'
         L     R11,PDLPTR      ESTABLISH PARM ADDRESSABILITY
         USING IKJPARMD,R11
         L     R9,OPER1        LOAD OPERAND ADDRESS
         LH    R8,OPER1+4      LOAD OPERAND LENGTH
         LA    R15,2(,R8)      INCREMENT LENGTH FOR IKJDAIR
         STH   R15,DSNAME      STORE FOR IKJDAIR
         BCTR  R8,R0           DECREMENT FOR EXEC
         LA    R7,INFILE       LOAD RECEIVING ADDRESS FOR EXEC
         EX    R8,MOVEIT       EXECUTE
         OC    INFILE,BLNKS    FOLD TO UPPERCASE
         CLC   INFILE(8),=C'Z7999999'
         BNE   SKIP112         IMPLIES NO INPUT DATA, NO ALLOCATION
         MVI   FLAGDS,X'00'
         MVI   FLAGNODA,X'01'
         MVC   INFILE(44),BLNKS
         B     NODATA          IMPLIES NO INPUT DATA, NO ALLOCATION
SKIP112  TM    OPER1+14,X'80'  IS THERE A MEMBER NAME AS WELL?
         B     ALLOCATE        @REPLACEMENT
*        BZ    ALLOCATE
*        L     R9,OPER1+8      AS ABOVE BUT FOR MEMBER NAME
*        LH    R8,OPER1+12
*        BCTR  R8,R0
*        LA    R7,MEMBER
*        EX    R8,MOVEIT
*        OC    MEMBER,BLNKS    FOLD TO UPPERCASE
*        B     ALLOCATE
REALLOC  L     R5,DAPARMSA           ESTABLISH ADDRESSABILITY
         USING DAPL,R5
         L     R6,DAFREEA            ESTABLISH ADDRESSABILITY
         USING DAPB18,R6
         ST    R6,DAPLDAPB
         XC    0(44,R6),0(R6)
         MVI   DA18CD+1,X'18'        SET CODE TO DEALLOCATE
         MVC   DA18DDN,INPDD         MOVE IN DDNAME USED BY SYSTEM
         LA    R1,DAPL               POINT TO PARM LIST
         LINK  EP=IKJDAIR,MF=(E,(1)) DEALLOC
         CLC   BLNKS(8),MEMBER
         BNE   ALLOCATE
         MVI   FLAGNODA,X'01'
         MVI   FLAGPDS,X'01'
         B     NODATA
ALLOCATE L     R5,DAPARMSA     ESTABLISH ADDRESSABILITY FOR IKJDAIR
         USING DAPL,R5
         XC    0(168,R5),0(R5)
         MVC   DAPLUPT,CPPLUPT
         MVC   DAPLECT,CPPLECT
         MVC   DAPLPSCB,CPPLPSCB
         L     R9,ECBADDR
         ST    R9,DAPLECB
         L     R6,DAALLOA      ESTABLISH ADDRESSABILITY FOR ALLOCATE
         USING DAPB08,R6
         LA    R9,DAPB08
         ST    R9,DAPLDAPB
         MVI   DA08CD+1,X'08'  SET CODE TO ALLOCATE
         LA    R9,DSNAME       MOVE IN DSNAME ADDRESS
         ST    R9,DA08PDSN
         MVC   DA08DDN,BLNKS         CLEAR DDNAME
         MVC   DA08UNIT(8),BLNKS           UNIT
         MVC   DA08SER(8),BLNKS            VOLSER
         MVC   DA08MNM(8),MEMBER           MEMBER NAME
         MVC   DA08PSWD(8),BLNKS           PWORD
         OI    DA08DSP1,DA08SHR      SET DISP TO SHR,KEEP,KEEP
         OI    DA08DPS2,DA08KEEP
         OI    DA08DPS3,DA08KEEP
         LA    R1,DAPL         POINT TO LIST
         LINK  EP=IKJDAIR,MF=(E,(1))
         LTR   R15,R15         ALLOCATE OK?
         BZ    SKIP021
         MVI   FLAGO,X'00'
         MVI   FLAGNODA,X'01'
         CLC   MEMBER(8),BLNKS
         BNE   ERROR16
         B     ERROR7          NO, ERROR
SKIP021  MVC   INPDD(8),DA08DDN      SAVE DDNAME
         MVC   PHSDD+40(8),DA08DDN   MOVE DDNAME TO PHSDD AREA
         MVC   PDSDD+40(8),DA08DDN   MOVE DDNAME TO PHSDD AREA
         CLI   FLAGPDS,X'01'
         BE    NODATA
         MVC   DSORG,DA08DSO
         TM    DSORG,X'02'         IS DSORG PARTITIONED?
         BNO   SKIP331             YES, BRANCH
         MVI   FLAGPDS,X'01'
         MVI   FLAGNODA,X'01'
REREADD  L     R1,LENGTHD
         GETMAIN  R,LV=(1)
         ST    R1,ADDRESS3
         ST    R1,DIRPTR
         OPEN  (PDSDD,(INPUT))
         L     R6,ADDRESS3
         A     R6,LENGTHD
         SH    R6,=H'8'
         ST    R6,ADDRESS6
         L     R6,ADDRESS3
         L     R7,DIRARAD
RDLOOP   READ  DIRECT,SF,PDSDD,(7),256  READ DIR BLOCK
         CHECK DIRECT         WAIT
         SR    R5,R5          ZERO R5
         MVC   BYTECNT,0(R7)     SAVE BYTE CNT
         LA    R5,2(,R5)      MOVE POINTER ON
         SR    R9,R9          ZERO R9
         B     CON1
MBRLOP   IC    R9,11(R5,R7)             PICK OUT USER DATA CNT
         N     R9,=XL4'1F'              MASK OUT BITS 0-2
         SLL   R9,1                     MULTIPY HALFWORDS FOR BYTES
         LA    R5,12(R9,R5)             SET R5 TO START OF NEXT ENTRY
         CH    R5,BYTECNT               END OF THIS BLOCK
         BNL   RDLOOP                   YES - BRANCH
CON1     LA    R11,0(R5,R7)             SET R11 TO START OF MEMBER NAM
         CLC   FINNAM(8),0(R11)         CHECK FOR SPECIAL NAME
         BE    FINISH                   YES - BRANCH
         MVC   0(8,R6),0(R11)  MOVE MEMBER NAME
         OC    0(8,R6),BLNKS
         MVI   FLAGMEM,X'01'
         LA    R6,8(,R6)
         C     R6,ADDRESS6
         BL    MBRLOP
         MVI   FLAGPDS,X'02'
FINISH   MVI   0(R6),X'FF'              END OF LIST MARK
         ST    R6,ADDRESS4
         CLOSE (PDSDD)
         CLI   FLAGPDS,X'02'
         BNE   NODATA
         MVI   FLAGPDS,X'01'
         B     ERROR19
SKIP331  TM    DSORG,X'40'         IS DSORG SEQUENTIAL?
         BO    NODATA              YES, BRANCH
         MVI   FLAGDS,X'00'
         B     ERROR10
OPEN2    OPEN (PHSDD,(INPUT))  OPEN DATASET
         LTR   R15,R15
         BNZ   NODATA
         TM    PHSDD+48,X'10'  OPEN OK?
         BO    NEXTXX1         NO, ERROR
         MVI   FLAGDS,X'00'
         B     ERROR3
NEXTXX1  TM    PHSDD+36,X'80'  FIXED?
         BNO   NEXTXX3
         TM    PHSDD+36,X'40'  "
         BNO   NEXTXX2
NEXTXX3  MVI   FLAGDS,X'00'
         B     ERROR6
NEXTXX2  MVI   FLAGNODA,X'00'
SKIP124  L     R2,ADDRESS      POINT R2 TO SCREEN BEGINNING
         A     R2,WIDTH
         AH    R2,=H'1'
         L     R3,WIDTH        LOAD R3 WITH SCREEN WIDTH
         CH    R3,PHSDD+82     GET-LENGTH IS MINIMUM(R3,RECORD LENGTH)
         BL    DOIT
         LH    R3,PHSDD+82
DOIT     BCTR  R3,R0           DECREMENT FOR EXEC
GETIT    GET   PHSDD           FETCH RECORD
         EX    R3,MOVEIT2      MOVE IT FROM BUFFER TO SCREEN
         A     R2,WIDTH        INCREMENT SCREEN POINTER FOR NEXT RECORD
         C     R2,LIMIT
         BL    GETIT           AND AGAIN UNTIL END OF SCREEN
ENDFIL   CLOSE (PHSDD)         CLOSE INPUT DATA SET
NODATA   STFSMODE ON,INITIAL=YES
         CLI   FLAGO,X'01'
         BNE   DUMMKOPF
         MVI   FLAGO,X'00'
         CLI   FLAGNO,X'01'
         BE    OUTOFIT
         B     DISPLAY2        DISPLAY THE INITIAL SCREEN
SCAN     CLI   FLAGIN,X'01'
         BNE   OTHER4
         MVI   FLAGIN,X'00'
         SR    R3,R3
         ST    R3,GENREAL
         B     ERROR18
OTHER4   L     R2,ADDRESS      PREPARE FOR SCAN
         LA    R2,1(,R2)       MOVE BOTTOM ROW TO TOP ROW-1
         L     R4,LIMIT          SO THAT SCREEN AEFFECTIVELY
         S     R4,WIDTH          WRAPS AROUND TOP TO BOTTOM
         L     R3,WIDTH          DURING GENERATION PROCESSING
         LR    R5,R3
         MVCL  R2,R4           GREAT..NOW
         L     R2,ADDRESS      MOVE TOP ROW TO BOTTOM ROW+1
         A     R2,WIDTH          FOR THE ABOVEMENTIONED REASON
         LA    R2,1(,R2)
         L     R4,LIMIT
         L     R3,WIDTH
         LR    R5,R3
         MVCL  R4,R2           NICE
         L     R3,ADDRESS      UNIVERSAL CONSTANT!
         LR    R9,R3
         A     R9,WIDTH        R9 IS THE CURRENT CELL POINTER
         LA    R9,1(,R9)       TRUE BEGINNING
         LA    R6,1(,R3)       R6 IS VERY USEFUL!!!!!
         MVC   POPLAST(4),POPCUR
         SR    R11,R11         R11 ACCUMUALATES #CHANGES/GENERATION
         L     R5,WIDTH
         SH    R5,=H'2'        R5 IS AN OFT NEEDED CONSTANT
         SR    R4,R4           R4 IS THE EDGE DETECTOR
LOOP     LR    R7,R3           R7 IS THE ADDRESS FOR NEIGHB TEST
         SR    R8,R8           R8 IS THE NEIGHBOUR COUNT
         C     R4,WIDTH        IS R4 AT THE EDGE?..DIFFERENT PROCESSING
         BNE   R4OK               AT THE EDGE SIMULATES LEFT-RIGHT WRAP
         SR    R4,R4           YES; ZERO IT
R4OK     LTR   R4,R4           IF R4 IS ZERO, LEFT EDGE
         BZ    LEDGE           PROCEED TO LEFT EDGE COMPARISON
         LA    R2,1(,R4)
         C     R2,WIDTH        IF R4 IS WIDTH-1, RIGHT EDGE
         BE    REDGE           PROCEED TO RIGHT EDGE COMPARISON
         CLI   0(R7),X'FD'
         BNH   OVER$01
         LA    R8,1(,R8)
OVER$01  CLI   1(R7),X'FD'
         BNH   OVER$02
         LA    R8,1(,R8)
OVER$02  CLI   2(R7),X'FD'
         BNH   OVER$03
         LA    R8,1(,R8)
OVER$03  LA    R7,2(R5,R7)
         CLI   0(R7),X'FD'
         BNH   OVER$04
         LA    R8,1(,R8)
OVER$04  CLI   2(R7),X'FD'
         BNH   OVER$05
         LA    R8,1(,R8)
OVER$05  LA    R7,2(R5,R7)
         CLI   0(R7),X'FD'
         BNH   OVER$06
         LA    R8,1(,R8)
OVER$06  CLI   1(R7),X'FD'
         BNH   OVER$07
         LA    R8,1(,R8)
OVER$07  CLI   2(R7),X'FD'
         BNH   TALLY
         LA    R8,1(,R8)
         B     TALLY           COMPARISONS DONE; ESTABLISH CELL FATE
LEDGE    CLI   1(R7),X'FD'
         BNH   OVER$08
         LA    R8,1(,R8)
OVER$08  CLI   2(R7),X'FD'
         BNH   OVER$09
         LA    R8,1(,R8)
OVER$09  LA    R7,2(R5,R7)
         CLI   0(R7),X'FD'
         BNH   OVER$10
         LA    R8,1(,R8)
OVER$10  CLI   2(R7),X'FD'
         BNH   OVER$11
         LA    R8,1(,R8)
OVER$11  LA    R7,2(R5,R7)
         CLI   0(R7),X'FD'
         BNH   OVER$12
         LA    R8,1(,R8)
OVER$12  CLI   1(R7),X'FD'
         BNH   OVER$13
         LA    R8,1(,R8)
OVER$13  CLI   2(R7),X'FD'
         BNH   OVER$14
         LA    R8,1(,R8)
OVER$14  LA    R7,2(R5,R7)
         CLI   0(R7),X'FD'
         BNH   TALLY
         LA    R8,1(,R8)
         B     TALLY
REDGE    SR    R7,R5
         CLI   0(R7),X'FD'
         BNH   OVER$15
         LA    R8,1(,R8)
OVER$15  AR    R7,R5
         CLI   0(R7),X'FD'
         BNH   OVER$16
         LA    R8,1(,R8)
OVER$16  CLI   1(R7),X'FD'
         BNH   OVER$17
         LA    R8,1(,R8)
OVER$17  CLI   2(R7),X'FD'
         BNH   OVER$18
         LA    R8,1(,R8)
OVER$18  LA    R7,2(R5,R7)
         CLI   0(R7),X'FD'
         BNH   OVER$19
         LA    R8,1(,R8)
OVER$19  CLI   2(R7),X'FD'
         BNH   OVER$20
         LA    R8,1(,R8)
OVER$20  LA    R7,2(R5,R7)
         CLI   0(R7),X'FD'
         BNH   OVER$21
         LA    R8,1(,R8)
OVER$21  CLI   1(R7),X'FD'
         BNH   OVER$22
         LA    R8,1(,R8)
OVER$22  LR    R7,R5
         LA    R7,1(,R7)         TRANSLATE FF AND FD TO FF AND FE TO
         LR    R2,R3             BLANK IN PREVIOUS ROW, SINCE IT WILL
         SR    R2,R5             NOT BE NEEDED FOR ANY MORE
         EX    R7,TRANIT         COMPARISONS.
TALLY    SLA   R8,2            MULTIPLY NEIGHBOUR CNT BY FOUR
         B     *+4(8)            BRANCH ON THIS VALUE (PLUS 4)
         B     FOURPLUS          ZERO NEIGHBOURS
         B     FOURPLUS          ONE NEIGHBOUR
         B     NEXT9             TWO NEIGHBOURS; NOTHING HAPPENS
         B     THREE             THREE NEIGHBOURS
         B     FOURPLUS
         B     FOURPLUS
         B     FOURPLUS
         B     FOURPLUS
         B     FOURPLUS
THREE    CLI   0(R9),X'40'     THREE NEIGHBOURS; IF BLANK NEW CELL
         BNE   NEXT9
         MVI   0(R9),X'FD'
         LA    R11,1(,R11)     INCREMENT CHANGE COUNT
         B     NEXT889
FOURPLUS CLI   0(R9),X'40'     FOUR NEIGHBOURS; IF NONBLANK, DEAD CELL
         BE    NEXT889
         MVI   0(R9),X'FE'
         B     NEXT889
NEXT9    CLI   0(R9),X'FF'
         BNE   NEXT889
         LA    R11,1(,R11)
NEXT889  LA    R3,1(,R3)       INCREMENT COMPARE BASE REG
         LA    R4,1(,R4)                         EDGE REG
         LA    R9,1(,R9)                         CELL REG
         C     R9,LIMIT        END OF SCREEN?
         BL    LOOP            NO; LET'S GO AGAIN
         LR    R7,R5
         LA    R7,1(,R7)
         LA    R2,1(,R3)
         EX    R7,TRANIT       TRANSLATE FINAL ROW
         SR    R2,R2
         ST    R11,POPCUR
         C     R11,POPLAST
         BNE   AROUND10        IF #CHANGES IS SAME AS LAST TIME..
         L     R2,ACCUM2          INCREMENT #TIMES(#CHANGES UNCHANGED)
         LA    R2,1(,R2)
         CH    R2,=H'1000'     IF CONSTANT FOR 10 GENS, ZERO
         BNL   XXFF               ACCUMULATORS AND DISPLAY VIA AROUND11
         C     R2,LIM          IF CONSTANT FOR LIMIT, ZERO
         BL    DDFF               ACCUMULATORS AND DISPLAY VIA AROUND11
XXFF     SR    R2,R2
         ST    R2,ACCUM2
         B     AROUND11
DDFF     ST    R2,ACCUM2       IF NOT YET 10 STORE NEW VALUE...
         B     DDFF2              AND SEE IF....
AROUND10 SR    R2,R2
         ST    R2,ACCUM2
DDFF2    LTR   R11,R11
         BNZ   OVER3T             BY REDUCING G TO ZERO
AROUND11 SR    R3,R3
         ST    R3,GENREAL
         B     DISPLAY
OVER3T   L     R3,GENCUR
         LA    R3,1(,R3)
         ST    R3,GENCUR
         L     R3,GENABS
         LA    R3,1(,R3)
         ST    R3,GENABS
OVER88   L     R3,GENREAL      DECREMENT G
         BCT   R3,TIMETEST
         ST    R3,GENREAL      STORE NEW G
         B     DISPLAY         IF G¬>0 THEN DISPLAY SCREEN
TIMETEST ST    R3,GENREAL
         CLI   FLAGTIME,X'01'
         BNE   NOTIMING
         MVC   TMEREAL,TME        RESET TIME FIELD
         STIMER WAIT,BINTVL=TMEREAL,ERRET=ERROR4
NOTIMING L     R3,INTREAL
         BCT   R3,CONTX        NB: I TEST IS DEPENDENT ON G TEST
         ST    R3,INTREAL         ELSE SAVE NEW I AND REPROCESS
         B     DISPLAY         IF I¬>0 THEN THEN DISPLAY SCREEN
CONTX    ST    R3,INTREAL         ELSE SAVE NEW I AND REPROCESS
         B     SCAN               THE COLONY
DISPLAY  L     R2,ADDRESS
         A     R2,WIDTH
         LA    R2,1(,R2)       TRUE BEGINNING
         IC    R1,CHAR
         STC   R1,NUMBERS2+255   PUT CURRENT CHAR AT X'FF' IN TABLE
         L     R7,WIDTH
         BCTR  R7,R0           WIDTH-1 FOR EXEC
LOOPE    EX    R7,TRANIT       XLATE A ROW
         A     R2,WIDTH        INCREMENT TO NEXT ROW
         C     R2,LIMIT
         BL    LOOPE           REPEAT UNTIL END OF SCREEN
         MVI   NUMBERS2+255,X'FF'  RESTORE X'FF' LOCATION TO X'FF'
         MVI   FLAGRAW,X'00'
         L     R3,GENREAL
         LTR   R3,R3           IF G ZERO THEN DO A TGET.....
         BNP   DISPLAY2
         L     R3,PAU          GET PAUSE VALUE AND IF >0 THEN STIMER
         LTR   R3,R3           PAU IS IN MILLISECONDS
         BNP   DISPLAY2        DISPLAY IF ZERO
         MVC   PAUREAL,PAU     REPLACE
         STIMER WAIT,BINTVL=PAUREAL,ERRET=ERROR4
DISPLAY2 STFSMODE ON,INITIAL=YES
         SR    R1,R1
         SR    R0,R0
         L     R1,ADDRESS
         A     R1,WIDTH
         SH    R1,=H'4'        SCREEN START MINUS FIVE FOR PREFIX
         MVC   0(5,R1),FIELD   MOVE TPUT PREFIX IN
         SR    R5,R5
         L     R5,GENCUR
         LTR   R5,R5
         BZ    OVER2
         SR    R3,R3
         L     R3,GENREAL
         LTR   R3,R3           IF G ZERO THEN DO A TGET.....
         BNP   OVER2
         CLI   FLAGSTAT,C'Y'
         BNE   OVER2
         LR    R2,R1
         L     R6,TEMPDAAD
         MVC   0(12,R6),5(R2)
         A     R2,WIDTH
         LA    R6,12(,R6)
         MVC   0(12,R6),5(R2)
         A     R2,WIDTH
         LA    R6,12(,R6)
         MVC   0(12,R6),5(R2)
         A     R2,WIDTH
         LA    R6,12(,R6)
         MVC   0(12,R6),5(R2)
         LR    R2,R1
         MVC   5(12,R2),=C'+----------+'
         A     R2,WIDTH
         CVD   R5,PACKAREA
         MVC   5(3,R2),=C'|G>'
         MVC   8(8,R2),PATTGEN
         ED    8(8,R2),PACKAREA+4
         MVI   16(R2),C'|'
         A     R2,WIDTH
         MVC   5(3,R2),=C'|P>'
         L     R5,POPCUR
         CVD   R5,PACKAREA
         MVC   8(8,R2),PATTGEN
         ED    8(8,R2),PACKAREA+4
         MVI   16(R2),C'|'
         A     R2,WIDTH
         MVC   5(12,R2),=C'+----------+'
         MVI   FLAGTEMP,X'01'
OVER2    ICM   R1,8,PUTR1      ADJUST HIGH ORDER BYTE FOR TPUT
         L     R0,LENGTH       LOAD LENGTH OF SCREEN+5
         SR    R15,R15         CLEAR
         TPUT  (1),(0),R       DISPLAY
*        LTR   R15,R15         OK?
*        BNZ   ERROR9          NO
         SR    R1,R1
         L     R1,ADDRESS
         A     R1,WIDTH
         SH    R1,=H'4'        SCREEN START MINUS FIVE FOR PREFIX
         CLI   FLAGSTAT,C'Y'
         BNE   SKIP91
         CLI   FLAGTEMP,X'01'
         BNE   SKIP91
         MVI   FLAGTEMP,X'00'
         LR    R2,R1
         L     R6,TEMPDAAD
         MVC   5(12,R2),0(R6)
         A     R2,WIDTH
         LA    R6,12(,R6)
         MVC   5(12,R2),0(R6)
         A     R2,WIDTH
         LA    R6,12(,R6)
         MVC   5(12,R2),0(R6)
         A     R2,WIDTH
         LA    R6,12(,R6)
         MVC   5(12,R2),0(R6)
SKIP91   MVC   INTREAL,INT     RESTORE I
         L     R3,GENREAL
         LTR   R3,R3           IF G ZERO THEN DO A TGET.....
         BNP   PROCURE
         L     R2,ADDRESS      ELSE TRANSLATE CHAR BACK TO X'FF'
         A     R2,WIDTH
         LA    R2,1(,R2)       TRUE BEGINNING
*        CLI   CHAR,X'40'      IF CHAR IS BLANK THEN NO CHANGE
*        BE    AROUNDX
         LA    R9,NUMBERS2     XLATE TABLE ADDRESS
         SR    R5,R5           CLEAR
         IC    R5,CHAR
         AR    R5,R9           XLATE BASE PLUS CHAR GIVES TABLE ADDRESS
         MVI   0(R5),X'FF'     MOVE IN X'FF'
AROUNDX  L     R7,WIDTH
         BCTR  R7,R0           WIDTH-1
LOOPG    EX    R7,TRANIT       XLATE A ROW
         A     R2,WIDTH        INCREMENT TO NEXT ROW
         C     R2,LIMIT
         BL    LOOPG           REPEAT TO END OF SCREEN
         MVI   0(R5),X'40'     RESTORE TABLE ENTRY
         MVI   FLAGRAW,X'01'
         B     SCAN            PROCESS GENERATION
PROCURE  MVI   FLAGIN,X'00'
         SR    R1,R1
         L     R1,ADDRESS
         A     R1,WIDTH
         SH    R1,=H'2'        SCREEN START MINUS THREE FOR.......
         LR    R2,R1             CURSOR POSITION
         ICM   R1,8,GETR1
         SR    R0,R0
         L     R0,LENGTHG      SCREEN PLUS THREE
         TGET  (1),(0),R       GET
*        LTR   R15,R15         OK?
*        BNZ   ERROR9          NO
         NI    0(R2),X'0F'     FOLD RESPONSE VALUE
         CLI   0(R2),X'03'     END KEY?
         BE    ERROR11         YES
         CLI   0(R2),X'04'     RESTORE KEY?
         BNE   NEXT4
         CLI   FLAGDS,X'00'
         BE    ERROR17         IF NO INPUT DSET, DISPLAY AGAIN
         CLI   FLAGNODA,X'01'
         BNE   SKIP555         IF NO INPUT DSET, DISPLAY AGAIN
         CLI   FLAGPDS,X'01'
         BNE   ERROR14
         MVI   FLAGNO,X'01'
         BE    CDIR2
SKIP555  CLI   FLAGNEWM,X'01'
         BE    ERROR14         IF NO INPUT DSET, DISPLAY AGAIN
         LA    R4,BLNKS
         L     R2,ADDRESS
         L     R3,STORAGE
         L     R5,PADDING      ERASE SCREEN AREA....
         MVCL  R2,R4           FILL GETMAINED AREA WITH PAD OF BLANK
         MVI   FLAGO,X'01'
         B     OPEN2           AND REREAD DATA SET
NEXT4    CLI   0(R2),X'05'     SAVE?
         BE    RESTORE         YES
         CLI   0(R2),X'0C'     ROTATE?
         BE    ROTATE          YES
         CLI   0(R2),X'02'     CENTRE THE OBJECT?
         BE    CENTRE
         CLI   0(R2),X'06'     REFLECT LEFT-RIGHT?
         BE    REFLECT1
         CLI   0(R2),X'09'     REFLECT UP-DOWN?
         BE    REFLECT2
         CLI   0(R2),X'07'     SCROLL UP?
         BE    USHIFT
         CLI   0(R2),X'08'     SCROLL DOWN?
         BE    DSHIFT
         CLI   0(R2),X'0E'     DISPLAY?
         BNE   SKIP12
         MVI   FLAGDIS,X'01'
         B     BUGGERIT
SKIP12   CLI   0(R2),X'0A'     SCROLL LEFT?
         BNE   NEXT88
         L     R5,MO2          IF SO, R5 MUST CONTAIN M
         B     LSHIFT
NEXT88   CLI   0(R2),X'0B'     SCROLL RIGHT?
         BNE   NEXT99
         L     R5,WIDTH        YES; SCROLL LEFT WITH R5=WIDTH-M
         S     R5,MO2           (MORE ECONOMICAL)
         BP    LSHIFT
         B     DISPLAY2
NEXT99   CLI   0(R2),X'01'     HELP SCREEN?
         BNE   BUGGERIT        NO, BUGGER IT
         B     DUMMKOPF        YES, HELP THE DUMMKOPF
BUGGERIT L     R9,ADDRESS      FIRST SCAN SCREEN FOR COMMANDS
         A     R9,WIDTH
         LA    R9,1(,R9)       TRUE BEGINNING
LOOPC    CLI   1(R9),C'='      IS IT AN EQUAL SIGN?
         BE    COMMAND         YES!
AGAIN    LA    R9,1(,R9)       NO, INCREMENT AND TRY AGAIN
         C     R9,LIMIT
         BL    LOOPC
         CLI   FLAGDIS,X'01'
         BE    CDIS
TRYO1    CLI   FLAGDIR,X'01'
         BNE   TRYO2
         CLI   FLAGPDS,X'01'
         BE    CDIR2
         MVI   FLAGDIR,X'00'
         B     ERROR17
TRYO2    CLI   FLAGDS,X'01'
         BNE   OUTOFIT
         CLI   FLAGO,X'01'
         BNE   OUTOFIT         END OF SCREEN; OUT
*        MVI   FLAGNO,X'00'
         B     REALLOC
COMMAND  OI    0(R9),X'40'     FOLD VERB
         CLI   0(R9),C'C'      IF C COMMAND SPECIAL PROCESSING...
         BE    CCHA
         CLI   0(R9),C'S'      IF S COMMAND SPECIAL PROCESSING...
         BE    CSHO
         CLI   0(R9),C'M'      IF M COMMAND SPECIAL PROCESSING...
         BE    COPE
         CLI   0(R9),C'D'      IF D COMMAND SPECIAL PROCESSING...
         BE    CDIR
         CLI   0(R9),C'R'      IF R COMMAND SPECIAL PROCESSING...
         BNE   OVER9
         SR    R5,R5           CLEAR
         LA    R5,2(,R5)       LENGTH TWO
         SR    R6,R6
         ST    R6,GENCUR
         B     CLEAN
OVER9    LA    R4,2(,R9)       ELSE XLATE AND TEST FOR FIRST
         SR    R1,R1                NONUMERIC AFTER THE EQUAL SIGN
         TRT   0(8,R4),NUMBERS
         BZ    AGAIN           IF LENGTH EIGHT, NO GOOD. START AGAIN
         SR    R1,R4           LENGTH OF NUMERIC
         LA    R5,1(,R1)       ADDRESS OF NUMERIC
         SH    R1,=H'1'        LENGTH-1 FOR EXEC
         BM    AGAIN           IF LENGTH¬>0 THEN BACK TO START
         MVC   TEMPAREA(8),BLNKS
         EX    R1,MOVEIT9      PACK NUMERIC
         EX    R1,PACK         PACK NUMERIC
         CVB   R1,PACKAREA     CONVERT TO BINARY
         CLI   0(R9),C'T'      NOW, WAS COMMAND T?
         BE    CTME
         CLI   0(R9),C'G'      OR G?
         BE    CGEN
         CLI   0(R9),C'P'      OR P?
         BE    CPAU
         CLI   0(R9),C'I'      OR I?
         BE    CINT
         CLI   0(R9),C'V'      OR M?
         BE    CMO1
         CLI   0(R9),C'H'      OR M?
         BE    CMO2
         CLI   0(R9),C'L'      OR L?
         BE    CLIM
         B     AGAIN           NONE OF THESE! BACK TO START
CCHA     CLI   2(R9),C' '
         BNE   YESTHANX
         MVI   FLAGCL,X'01'
         B     NOTHANX
YESTHANX MVC   OLDCHAR,CHAR    C COMMAND; CHAR BECOMES OLD CHAR
         MVC   XXCHAR,EXCHAR
         MVC   EXCHAR,CHAR
         MVC   CHAR,2(R9)      BYTE IMMEADIATELY AFTER = IS NEW CHAR
         MVI   FLAGCL,X'00'
NOTHANX  SR    R5,R5           CLEAR
         LA    R5,2(,R5)       LENGTH TWO
         B     CLEAN           CLEAN UP CODE
CDIR     SR    R5,R5           CLEAR
         LA    R5,2(,R5)       LENGTH TWO
         MVI   FLAGDIR,X'01'
         B     CLEAN           CLEAN UP CODE
CSHO     OI    2(R9),X'40'
         CLI   2(R9),C'Y'
         BNE   SKIP88
         MVI   FLAGSTAT,C'Y'
         B     SKIP89
COPE     LA    R6,2(,R9)
         SR    R5,R5
         MVI   FLAGNO,X'01'
LOOP123  CLI   0(R6),C' '
         BE    GOTIT123
         LA    R6,1(,R6)
         LA    R5,1(,R5)
         CH    R5,=H'8'
         BNH   LOOP123
GOTIT123 LTR   R5,R5
         BNZ   OK123
         MVC   MEMBER(8),BLNKS
         LA    R5,2(,R5)
         EX    R5,MOVEIT4      BLANK OUT COMMAND AND NUMERIC
         CLI   FLAGPDS,X'01'
         BNE   AGAIN
         MVI   FLAGO,X'01'
         B     AGAIN           TRY NEXT BYTE
OK123    BCTR  R5,R0
         MVC   TEMPMEM(8),MEMBER
         MVC   MEMBER(8),BLNKS
         EX    R5,MOVEIT10
         LA    R5,2(,R5)
         EX    R5,MOVEIT4      BLANK OUT COMMAND AND NUMERIC
         OC    MEMBER,BLNKS
         CLI   FLAGPDS,X'01'
         BE    SKIP007
         MVC   MEMBER(8),BLNKS
         B     AGAIN
SKIP007  L     R3,ADDRESS3
LOOPM1   CLC   MEMBER(8),0(R3)
         BE    OKDOKEY
         LA    R3,8(,R3)
         C     R3,ADDRESS4
         BNH   LOOPM1
         MVI   FLAGNEWM,X'01'
         MVI   FLAGO,X'01'
         MVI   FLAGNODA,X'00'
*        MVC   MEMBER(8),TEMPMEM
         B     AGAIN
OKDOKEY  MVI   FLAGO,X'01'
         MVI   FLAGNODA,X'00'
         MVI   FLAGNEWM,X'00'
         B     AGAIN
SKIP88   CLI   2(R9),C'N'
         BNE   SKIP89
         MVI   FLAGSTAT,C'N'
SKIP89   SR    R5,R5           CLEAR
         LA    R5,2(,R5)       LENGTH TWO
         B     CLEAN           CLEAN UP CODE
CDIS     MVI   FLAGNO,X'01'
         L     R2,IADDR
         USING INFODSC,R2
         L     R5,GENCUR
         CVD   R5,PACKAREA
         MVC   CGEN1X(8),PATTGEN
         ED    CGEN1X(8),PACKAREA+4
         L     R5,GENABS
         CVD   R5,PACKAREA
         MVC   AGEN1X(8),PATTGEN
         ED    AGEN1X(8),PACKAREA+4
         L     R5,POPCUR
         CVD   R5,PACKAREA
         MVC   POP1X(8),PATTGEN
         ED    POP1X(8),PACKAREA+4
         MVC   SHO1X(1),FLAGSTAT
         MVC   CHAR1X(1),CHAR
         MVC   CHAR2X(1),EXCHAR
         MVC   INT1X(8),INTCH
         MVC   MOV1X(8),MO1CH
         MVC   MOV2X(8),MO2CH
         MVC   TME1X(8),TMECH
         MVC   GEN1X(8),GENCH
         MVC   PAU1X(8),PAUCH
         MVC   LIM1X(8),LIMCH
         MVC   DSN1X(44),INFILE
         MVC   MEM1X(8),MEMBER
         DROP  R2
         L     R1,STORAGE      TOTAL NUMBER OF BYTES FOR THE DISPLAY
         MVI   FLAGDIS,X'00'
         GETMAIN  R,LV=(1)
         ST    R1,ADDRESS2     BEGINNING OF HELP DISPLAY AREA
         LA    R4,BLNKS        CLEAR THE STORAGE GAINED
         LR    R2,R1
         L     R3,STORAGE
         L     R5,PADDING
         MVCL  R2,R4           FILL GETMAINED AREA WITH PAD OF BLANK
         L     R2,IADDR        POINT TO HELP INFORMATION
         L     R1,ADDRESS2     POINT TO STORAGE
         A     R1,WIDTH
         AH    R1,=H'1'        START OF SCREEN WITHIN STORAGE
         L     R3,WIDTH        WIDTH OF SCREEN
         CH    R3,=H'80'       COMPARE TO HELP WIDTH
         BL    NEXT112         LOW? IF SO, TRUNCATE MOVE OPERATION
         LH    R3,=H'80'       NO; 80 BYTE MOVE OPERATION
NEXT112  BCTR  R3,R0           DECREMENT FOR EXEC
         L     R5,LIMI         HELP DEPTH
         C     R5,DEPTH        COMPARE TO SCREEN DEPTH
         BL    LOOPH2          LOW? IF SO, FULL HELP SCREEN
         L     R5,DEPTH        NO; SCREEN DEPTH SHORTENS HELP SCREEN
LOOPH2   EX    R3,MOVEIT3      MOVE A ROW
         A     R1,WIDTH        INCREMENT TO NEXT ROW
         LA    R2,80(,R2)      INCREMENT TO NEXT HELP ROW
         BCT   R5,LOOPH2       DECREMENT EFFECTIVE SCREEN DEPTH
RESHOW2  L     R1,ADDRESS2     FINISHED; TPUT IT AS WE NORMALLY DO
         A     R1,WIDTH
         SH    R1,=H'5'
         MVC   0(7,R1),FIELD2  HI INTENSITY PROTECTED
         ICM   R1,8,PUTR1      ADJUST HIGH ORDER BYTE FOR TPUT
         L     R0,LENGTH3      LENGTH
         SR    R15,R15         CLEAR
         TPUT  (1),(0),R       PUT IT
*        LTR   R15,R15         OK?
*        BNZ   ERROR9          NO; OUT
         L     R1,ADDRESS2
         A     R1,WIDTH
         SH    R1,=H'2'        FETCH A RESPONSE
         LR    R2,R1
         ICM   R1,8,GETR1
         L     R0,LENGTHG      LENGTH
         TGET  (1),(0),R       GET IT
*        LTR   R15,R15         OK?
*        BNZ   ERROR9          NO; OUT
         NI    0(R2),X'0F'
         CLI   0(R2),X'00'     INTERRUPT
         BNE   SKIP14
         STFSMODE ON,INITIAL=YES
         B     RESHOW2
SKIP14   L     R11,ADDRESS2
         LTR   R11,R11         GETMAIN PRESENT?
         BZ    ENDCDIS         NO; DISPLAY COLONY
         L     R1,STORAGE      YES; FREE STORAGE
         FREEMAIN R,A=(11),LV=(1)
ENDCDIS  B     TRYO1
CDIR2    MVI   FLAGDIR,X'00'
         MVI   FLAGNO,X'01'
         CLI   FLAGMEM,X'01'
         BNE   ERROR12
         L     R1,STORAGE2     TOTAL NUMBER OF BYTES FOR THE DISPLAY
         MVI   FLAGDIS,X'00'
         GETMAIN  R,LV=(1)
         ST    R1,ADDRESS2     BEGINNING OF HELP DISPLAY AREA
REDISPL  L     R1,ADDRESS2
         LA    R4,BLNKS        CLEAR THE STORAGE GAINED
         LR    R2,R1
         L     R3,STORAGE
         L     R5,PADDING
         MVCL  R2,R4           FILL GETMAINED AREA WITH PAD OF BLANK
         L     R1,ADDRESS2     POINT TO STORAGE
         A     R1,WIDTH
         AH    R1,=H'1'        START OF SCREEN WITHIN STORAGE
         L     R2,DIRPTR
         L     R3,WIDTH        WIDTH OF SCREEN
         CH    R3,=H'13'       COMPARE TO HELP WIDTH
         BL    NEXT912         LOW? IF SO, TRUNCATE MOVE OPERATION
         LH    R3,=H'13'       NO; 13 BYTE MOVE OPERATION
NEXT912  SH    R3,=H'5'        REMOVE PREFIX AREA
         BNP   NOMORE
         BCTR  R3,R0           DECREMENT FOR EXEC
         L     R6,MENUT
         L     R7,WIDTH
         CH    R7,=H'80'
         BNH   GOON
         LH    R7,=H'80'
GOON     BCTR  R7,R0
         EX    R7,MOVEIT12
         MVC   0(2,R1),PREF3
         A     R1,WIDTH
         LA    R1,1(,R1)
         L     R5,DEPTH        NO; SCREEN DEPTH SHORTENS HELP SCREEN
         BCTR  R5,R0
LOOPH8   C     R2,ADDRESS4
         BNL   OTHERPR
         EX    R3,MOVEIT11     MOVE A ROW
         MVC   0(5,R1),PREF
         B     ZOOM
OTHERPR  MVC   0(5,R1),PREF2
ZOOM     A     R1,WIDTH        INCREMENT TO NEXT ROW
         LA    R1,2(,R1)
         LA    R2,8(,R2)       INCREMENT TO NEXT HELP ROW
         BCT   R5,LOOPH8       DECREMENT EFFECTIVE SCREEN DEPTH
RESHOW3  L     R1,ADDRESS2     FINISHED; TPUT IT AS WE NORMALLY DO
         A     R1,WIDTH
         SH    R1,=H'7'
         MVC   0(8,R1),FIELD4
         ICM   R1,8,PUTR1      ADJUST HIGH ORDER BYTE FOR TPUT
         L     R0,LENGTH2      LENGTH
         SR    R15,R15         CLEAR
         TPUT  (1),(0),R       PUT IT
*        LTR   R15,R15         OK?
*        BNZ   ERROR9          NO; OUT
         L     R1,ADDRESS2
         LA    R1,2(,R1)
         LR    R2,R1
         ICM   R1,8,GETR1
         L     R0,LENGTHG2     LENGTH
         TGET  (1),(0),R       GET IT
*        LTR   R15,R15         OK?
*        BNZ   ERROR9          NO; OUT
         NI    0(R2),X'0F'
         CLI   0(R2),X'00'     INTERRUPT
         BNE   SKIP18
         STFSMODE ON,INITIAL=YES
         B     RESHOW3
SKIP18   CLI   0(R2),X'03'
         BE    NOMORE
SKIP188  CLI   0(R2),X'07'     UP?
         BNE   SKIP199
         L     R6,DEPTH
         BCTR  R6,R0           EXCLUDE TITLE
         MH    R6,=H'8'
         L     R5,DIRPTR
         SR    R5,R6
         C     R5,ADDRESS3
         BL    RESHOW3
         ST    R5,DIRPTR
         B     REDISPL
SKIP199  CLI   0(R2),X'08'     DOWN?
         BNE   SKIP099
         L     R6,DEPTH
         BCTR  R6,R0           EXCLUDE TITLE
         MH    R6,=H'8'
         L     R5,DIRPTR
         AR    R5,R6
         C     R5,ADDRESS4
         BNL   RESHOW3
         ST    R5,DIRPTR
         B     REDISPL
SKIP099  CLI   3(R2),X'11'
         BNE   RESHOW3
NEXT3    NI    4(R2),X'3F'     REDUCE BYTES 1,2 TO RIGHTMOST 6 BITS
         NI    5(R2),X'3F'
         SR    R5,R5           CLEAR REG 5 ....
         IC    R5,4(R2)                 AND LOAD IT WITH BYTE 1
         SLL   R5,6                  SHIFT IT LEFT SIX BITS
         SR    R3,R3           CLEAR REG3 .....
         IC    R3,5(R2)                 AND LOAD IT WITH BYTE 2
         AR    R5,R3                 ADD IT TO (BYTE 1(TIMES 2**6))
         LA    R5,1(,R5)       INCREMENT R5 FOR TRUE SCREEN POSITION
         L     R3,WIDTH        LOAD R3 WITH 80
         SR    R4,R4           CLEAR R4
         DR    R4,R3           DIVIDE R5 BY 80
         LA    R5,1(,R5)       INCREMENT FOR EXTRA LINE
         L     R3,ADDRESS2     LOAD R3 WITH CURRENT SCREEN ADDRESS
         L     R4,WIDTH
         AH    R4,=H'2'
         STH   R4,TEMPHALF
         MH    R5,TEMPHALF
         AR    R3,R5           ADD TO SCREEN ADDRESS
         LA    R3,3(,R3)
         MVC   MEMBER(8),0(R3)
         MVI   FLAGO,X'01'
         MVI   FLAGNODA,X'00'
         MVI   FLAGNEWM,X'00'
NOMORE   L     R11,ADDRESS2
         LTR   R11,R11         GETMAIN PRESENT?
         BZ    ENDCDIR2        NO; DISPLAY COLONY
         L     R1,STORAGE2     YES; FREE STORAGE
         FREEMAIN R,A=(11),LV=(1)
ENDCDIR2 B     TRYO2
CLIM     ST    R1,LIM          STORE NUMERIC IN L FIELD
         MVC   LIMCH,TEMPAREA
         B     CLEAN           CLEAN THIS AREA
CMO1     ST    R1,MO1          STORE NUMERIC IN M FIELD
         MVC   MO1CH,TEMPAREA
         MVI   FLAGNO,X'01'
         B     CLEAN           CLEAN THIS AREA
CMO2     ST    R1,MO2          STORE NUMERIC IN M FIELD
         MVC   MO2CH,TEMPAREA
         MVI   FLAGNO,X'01'
         B     CLEAN           CLEAN THIS AREA
CINT     ST    R1,INT          STORE NUMERIC
         MVC   INTCH,TEMPAREA
         MVC   INTREAL,INT     PROPAGATE TO TEMPORARY NUMERIC
         B     CLEAN           CLEAN
CTME     ST    R1,TME          AS ABOVE
         LTR   R1,R1
         BNZ   MOVEFLAG
         MVI   FLAGTIME,X'00'
         B     MOVECHAR
MOVEFLAG MVI   FLAGTIME,X'01'
MOVECHAR MVC   TMECH,TEMPAREA
         MVC   TMEREAL,TME
         B     CLEAN
CPAU     ST    R1,PAU          AS ABOVE
         MVC   PAUCH,TEMPAREA
         MVC   PAUREAL,PAU
         B     CLEAN
CGEN     ST    R1,GEN          AS ABOVE
         MVC   GENCH,TEMPAREA
         MVC   GENREAL,GEN     SO USER MUST HIT ENTER AGAIN FOR ACTION
CLEAN    EX    R5,MOVEIT4      BLANK OUT COMMAND AND NUMERIC
         B     AGAIN           TRY NEXT BYTE
OUTOFIT  CLI   FLAGCL,X'01'    NOW WE MUST TRANSLATE CHARACTERS
         BNE   SKIP97
         MVI   FLAGCL,X'00'
         B     ERASE
SKIP97   L     R2,ADDRESS      NOW WE MUST TRANSLATE CHARACTERS
         A     R2,WIDTH
         LA    R2,1(,R2)       TRUE BEGINNING
         CLI   CHAR,X'40'      IF CHAR PROVIDED WAS BLANK.....
         BE    AROUND9         DO NOT ADJUST XLATE TABLE....
         LA    R9,NUMBERS2     ELSE STORE X'FF' AT CHAR OFFSET
         SR    R5,R5                IN TABLE.....
         IC    R5,CHAR
         AR    R5,R9
         MVI   0(R5),X'FF'
         CLI   OLDCHAR,X'11'   IF OLD CHAR NONEXISTENT OR....
         BE    AROUND9
         CLI   OLDCHAR,X'40'   IF OLD CHAR IS BLANK THEN DO NOT ADJUST
         BE    AROUND9                XLATE TABLE...
         SR    R5,R5           ELSE STORE X'FF' AT CHAR OFFSET IN TABLE
         IC    R5,OLDCHAR
         AR    R5,R9
         MVI   0(R5),X'FF'
AROUND9  L     R7,WIDTH
         BCTR  R7,R0           WIDTH-1
LOOPZ    EX    R7,TRANIT       XLATE ROW
         A     R2,WIDTH        INCREMENT TO NEXT ROW
         C     R2,LIMIT
         BL    LOOPZ           REPEAT TO END OF SCREEN
         LA    R9,NUMBERS2     RESTORE CHAR OFFSET OF TABLE TO BLANK
         SR    R5,R5
         IC    R5,CHAR
         AR    R5,R9
         MVI   0(R5),X'40'
         SR    R5,R5
         CLI   OLDCHAR,X'11'   RESTORE OLD CHAR OFFSET TO BLANK
         BE    AROUND3
         IC    R5,OLDCHAR
         AR    R5,R9
         MVI   0(R5),X'40'
         MVI   OLDCHAR,X'11'   OLD CHAR HAS DIED NOW!
AROUND3  L     R5,INTREAL      NOW ADJUST PAUSE VALUE...
         SR    R4,R4           TIME IS WAIT BETWEEN GENS...
         L     R6,TME          AND PAUSE IS WAIT TIME BETWEEN DISPLAYS
         MR    R4,R6           SO PAUSE IS PAUSE-TIME*INTERVAL
         L     R6,PAU
         SR    R6,R5
         BP    AROUND8         IF P-T*I¬>0 THEN SET TO ZERO
         SR    R6,R6
AROUND8  ST    R6,PAU          STORE PAUSE VALUE
         MVC   GENREAL,GEN
         MVI   FLAGRAW,X'01'
         CLI   FLAGNO,X'01'
         BNE   NEXT333
         MVI   FLAGNO,X'00'
         SR    R6,R6
         ST    R6,GENREAL
         B     DISPLAY
NEXT333  L     R1,GEN
         LTR   R1,R1
         BNP   DISPLAY         IF G>0 THEN DISPLAY......
         SR    R6,R6
         ST    R6,POPCUR
         ST    R6,POPLAST
         B     SCAN            ELSE PROCESS
USHIFT   L     R5,MO1          UP SHIFT.....
         LTR   R5,R5           IF #ROWS=0 THEN OUT
         BZ    DISPLAY2
         C     R5,DEPTH        IF #ROWS>SCREENDEPTH THEN OUT
         BNL   DISPLAY2
SHIFTXP  L     R2,ADDRESS
         LA    R2,1(,R2)       TOP ROW-1 (ACTS AS A BUFFER)
         LR    R1,R2
         A     R1,WIDTH
         L     R7,WIDTH
         BCTR  R7,R0           WIDTH-1 FOR EXEC
SHIFTUP  EX    R7,MOVEIT2      MOVE THIS ROW TO NEXT ROW UP
         A     R1,WIDTH
         A     R2,WIDTH        NEXT ROW
         C     R1,LIMIT        END OF SCREEN?
         BL    SHIFTUP
         L     R1,ADDRESS      YES; NOW MOVE TOP ROW-1 (BUFFER)....
         LA    R1,1(,R1)            TO BOTTOM ROW (ALIAS TOP ROW)
         EX    R7,MOVEIT2
         BCT   R5,SHIFTXP      ANOTHER RUNG?
         CLI   FLAG,C'Y'       NO; CALLED BY CENTRE?
         BNE   DISPLAY2        NO; DISPLAY
         B     CENTRE2         YES; RETURN TO CENTRE
DSHIFT   L     R5,MO1
         LTR   R5,R5           ZERO SHIFT?
         BZ    DISPLAY2        OUT
         C     R5,DEPTH        LESS THAN SCREEN DEPTH?
         BNL   DISPLAY2        OUT
         L     R4,ADDRESS
         A     R4,WIDTH
         LA    R4,1(,R4)       SCREEN START
SHIFTXN  L     R2,LIMIT        BOTTOM ROW+1 (BUFFER ROW)
         LR    R1,R2
         S     R1,WIDTH        BOTTOM ROW
         L     R7,WIDTH
         BCTR  R7,R0           WIDTH-1 FOR EXEC
SHIFTDN  EX    R7,MOVEIT2      MOVE THIS ROW TO NEXT ONE DOWN
         S     R1,WIDTH
         S     R2,WIDTH        NEXT ROW UP
         CR    R2,R4           TOP OF SCREEN?
         BH    SHIFTDN         NO, AGAIN
         L     R1,LIMIT        YES; NOW MOVE BOTTOM ROW+1 TO TOP ROW
         LR    R2,R4                (THE BUFFER ROW ALIAS BOTTOM ROW)
         EX    R7,MOVEIT2
         BCT   R5,SHIFTXN      ANOTHER RUNG?
         CLI   FLAG,C'Y'       NO; CALLED BY CENTRE?
         BNE   DISPLAY2        NO; DISPLAY
         B     CENTRE2         YES; RETURN TO CENTRE
LSHIFT   LTR   R5,R5           ZERO SHIFT?
         BZ    ENDLEFT         OUT
         C     R5,WIDTH        >SCREENWIDTH?
         BNL   ENDLEFT         OUT
         L     R7,WIDTH
         SR    R7,R5           WIDTH-M (!!!)
         L     R1,ADDRESS
         A     R1,WIDTH
         LA    R1,1(,R1)       SCREEN START
SHIFTLX  L     R2,LIMIT        NOW MOVE FIRST R5 BYTES OF THIS ROW
         LR    R4,R2               TO BOTTOM ROW+1 (BUFFER)
         LR    R6,R5
         BCTR  R6,R0           DECREMENT FOR EXEC
         EX    R6,MOVEIT2      MOVE IT
         LR    R2,R1           NOW MOVE LAST WIDTH-R5 BYTES OF THIS ROW
         LR    R8,R1               TO LEFT OF THIS ROW (BYTE 1)
         AR    R1,R5           ROW START+M
         LR    R6,R7           WIDTH-M
         BCTR  R6,R0
         EX    R6,MOVEIT2      MOVEIT
         AR    R2,R7           NOW MOVE BUFFER ROW TO LAST R5 BYTES
         LR    R1,R4               OF THIS ROW (R2->THIS ROW+WIDTH-M)
         LR    R6,R5           R5 BYTES        (R4->BUFFER ROW)
         BCTR  R6,R0           DECREMENT FOR EXEC
         EX    R6,MOVEIT2
         LR    R1,R8           RESTORE R1 FROM R8 TEMPORARY STORAGE
         A     R1,WIDTH        NEXT ROW
         C     R1,LIMIT        END OF SCREEN?
         BL    SHIFTLX         NO; SHIFT IT LEFT
ENDLEFT  CLI   FLAGOK,X'01'    YES; DISPLAY IT
         BE    DISPLAY2        YES; DISPLAY IT
         B     RECENT
REFLECT2 L     R1,ADDRESS
         A     R1,WIDTH
         LA    R1,1(,R1)       R1 IS SCREEN START
         L     R3,LIMIT
         S     R3,WIDTH        R3 IS LAST ROW
         L     R2,LIMIT        R2 IS BUFFER ROW
         L     R7,WIDTH        NOW SWAP THE ROWS
         BCTR  R7,R0           WIDTH-1 FOR EXEC
ANOTHER  EX    R7,MOVEIT2      MOVE HIGH ROW TO BUFFER ROW
         EX    R7,MOVEIT5      MOVE LOW ROW TO HIGH ROW
         EX    R7,MOVEIT6      MOVE BUFFER ROW TO LOW ROW
         S     R3,WIDTH        INCREMENT LOW ROW
         A     R1,WIDTH        DECREMENT LOW ROW
         CR    R1,R3           HAVE THEY MET AT THE MIDDLE?
         BL    ANOTHER         NO; NEXT ROW
         B     DISPLAY2        YES; DISPLAY
REFLECT1 L     R1,ADDRESS
         LA    R1,1(,R1)
         LR    R2,R1           TOP ROW-1 (BUFFER)
         A     R1,WIDTH        SCREEN START
         L     R7,WIDTH
         BCTR  R7,R0           WIDTH-1 FOR EXEC
ARRR     EX    R7,MOVEIT2      MOVE THIS ROW TO BUFFER
         L     R5,ADDRESS
         A     R5,WIDTH        R5->LAST BYTE OF BUFFER ROW
         L     R6,WIDTH        R6 IS WIDTH
         LR    R4,R1           R4->THIS ROW
LOOPXX   MVC   0(1,R4),0(R5)   MOVE BUFFER(ENDBYTE)->THISROW(STARTBYTE)
         LA    R4,1(,R4)       INCREMENT START BYTE THIS ROW
         BCTR  R5,R0           DECREMENT END BYTE BUFFER ROW
         BCT   R6,LOOPXX       DECREMENT WIDTH UNTIL END OF THIS ROW
         A     R1,WIDTH        INCREMENT TO NEXT ROW
         C     R1,LIMIT        END OF SCREEN?
         BL    ARRR            NO; REVERSE THIS ROW ALSO
         B     DISPLAY2        YES; DISPLAY SCREEN
CENTRE   SR    R4,R4
         ST    R4,ACCUM
RECENT   MVI   FLAGOK,X'00'
         L     R4,ACCUM
         LA    R4,1(,R4)
         ST    R4,ACCUM
         CH    R4,=H'8'
         BL    SKIP94
         MVI   FLAGOK,X'01'
         B     DISPLAY2
SKIP94   L     R4,ADDRESS
         A     R4,WIDTH
         LA    R4,1(,R4)       SCREEN START
         SR    R8,R8           CLEAR COUNTER
LOPIT    CLC   0(1,R4),CHAR    IS THIS A LIVE CELL?
         BNE   NONO
         LA    R8,1(,R8)       YES; INCREMENT CELL COUNTER
NONO     LA    R4,1(,R4)       NEXT POSITION
         C     R4,LIMIT        END OF SCREEN?
         BL    LOPIT           NO; TEST IT
         LR    R9,R8           PREPARE FOR HALVING OF CELL COUNT
         LTR   R9,R9           ZERO COUNT?
         BZ    DISPLAY2        YES; DISPLAY SCREEN
         SR    R8,R8           CLEAR
         LH    R6,=H'2'        DIVISOR
         DR    R8,R6           DIVIDE
         ST    R9,TEMP         QUOTIENT
         L     R4,ADDRESS
         A     R4,WIDTH
         LA    R4,1(,R4)       SCREEN START
         SR    R3,R3           CLEAR
         SR    R7,R7           CLEAR
         SR    R8,R8           CLEAR
LOPIT2   CLC   0(1,R4),CHAR    LIVE CELL?
         BNE   NONO2
         LA    R8,1(,R8)       YES; INCREMENT TEMPORARY COUNTER
NONO2    LA    R4,1(,R4)       NEXT POSITION
         LA    R7,1(,R7)       INCREMENT END OF ROW DETECTOR
         C     R4,LIMIT        SCREEN END?
         BNL   FOUND           YES; OUT
         C     R7,WIDTH        END OF ROW?
         BL    LOPIT2          NO; NEXT BYTE
         C     R8,TEMP         YES; IS CELL COUNT > HALF TOTAL COUNT?
         BH    FOUND           YES; HALFWAY MARK
         LA    R3,1(,R3)       NO; INCREMENT ROW COUNTER
         SR    R7,R7           CLEAR END OF ROW DETECTOR
         B     LOPIT2          TRY AGAIN
FOUND    ST    R3,SHIFT1       STORE CENTER OF GRAVITY ROW NUMBER
         L     R4,ADDRESS
         A     R4,WIDTH
         LA    R4,1(,R4)       SCREEN START
         SR    R3,R3           CLEAR
         LR    R5,R4           CLEAR
         SR    R8,R8           CLEAR
LOPIT3   CLC   0(1,R4),CHAR    LIVE CELL?
         BNE   NONO3
         LA    R8,1(,R8)       YES; INCREMENT TEMPORARY COUNTER
NONO3    A     R4,WIDTH        NEXT ELEMENT OF COLUMN
         C     R4,LIMIT        BOTTOM OF SCREEN? (END OF COLUMN)
         BL    LOPIT3          NO; NEXT BYTE
         C     R8,TEMP         YES; IS CELL COUNT > HALF TOTAL COUNT?
         BH    FOUND2          YES; OUT
         LA    R5,1(,R5)       NO; INCREMENT COLUMN POINTER
         LR    R4,R5           POINT TO NEXT COLUMN
         LA    R3,1(,R3)       INCREMENT COLUMN COUNTER
         C     R3,WIDTH        END OF SCREEN?
         BL    LOPIT3          NO; GO AGAIN
FOUND2   ST    R3,SHIFT2       STORE CENTER OF GRAVITY COLUMN NUMBER
         MVI   FLAG,C'Y'       SET CENTRE FLAG
         L     R2,SHIFT1       R2 IS ROW NUMBER
         L     R7,DEPTH        DIVIDE SCREEN DEPTH BY 2
         SR    R6,R6
         LH    R5,=H'2'
         DR    R6,R5           RESULT IN R7
         CR    R7,R2           IS HALF DEPTH > CENTRE ROW?
         BL    UPSH            YES; SHIFT UP REQUIRED
         BNE   DNSH            IF EQUAL ALREADY CENTERED; CHECK COLUMN
         MVI   FLAGOK,X'01'
         B     CENTRE2
DNSH     SR    R7,R2           HALF DEPTH - ROW NUMBER
         LR    R5,R7           INTO R5
         L     R4,ADDRESS
         A     R4,WIDTH
         LA    R4,1(,R4)       POINT R4 TO SCREEN START
         B     SHIFTXN         CALL SHIFT DOWN CODE
UPSH     SR    R2,R7           ROW NUMBER - HALF DEPTH
         LR    R5,R2           INTO R5
         B     SHIFTXP         CALL SHIFT UP CODE
CENTRE2  MVI   FLAG,C'N'       RESET FLAG TO PRISTINE STATE
         L     R2,SHIFT2       R2 IS COLUMN NUMBER
         L     R7,WIDTH        DIVIDE WIDTH BY 2
         SR    R6,R6
         LH    R5,=H'2'
         DR    R6,R5           R7 IS HALF WIDTH
         CR    R7,R2           IS HALF WIDTH > CENTRE COLUMN?
         BL    RISH            NO; RIGHT SHIFT IT
         BNE   LESH            IF EQUAL ALREADY CENTERED; DISPLAY IT
         CLI   FLAGOK,X'01'
         BE    DISPLAY2
         B     RECENT
LESH     MVI   FLAGOK,X'00'
         SR    R7,R2           HALF WIDTH - COLUMN NUMBER
         L     R5,WIDTH        HALF WIDTH IS <= REAL HALF WIDTH
         SR    R5,R7           WIDTH - HALF WIDTH + COLUMN NUMBER
         B     LSHIFT           (¬ THE SAME AS HALF WIDTH + COLUMN!)
RISH     MVI   FLAGOK,X'00'
         SR    R2,R7           COLUMN NUMBER - HALF WIDTH
         LR    R5,R2           INTO R5
         B     LSHIFT          LEFT SHIFT
ERASE    L     R9,ADDRESS      CLEAN THE SCREEN
         A     R9,WIDTH
         LA    R9,1(,R9)       SCREEN START
COMPCC2  CLI   0(R9),C' '
         BE    DADADA
         MVI   0(R9),C' '
DADADA   LA    R9,1(,R9)
         C     R9,LIMIT
         BL    COMPCC2
         B     DISPLAY2
DUMMKOPF L     R1,STORAGE      TOTAL NUMBER OF BYTES FOR THE DISPLAY
         GETMAIN  R,LV=(1)
         ST    R1,ADDRESS2     BEGINNING OF HELP DISPLAY AREA
RESHOW   L     R1,ADDRESS2
         LA    R4,BLNKS
         LR    R2,R1
         L     R3,STORAGE
         L     R5,PADDING
         MVCL  R2,R4           FILL GETMAINED AREA WITH PAD OF BLANK
         L     R2,HADDR1
         CLC   FLAGWH,=H'1'
         BE    OTHER1
         L     R2,HADDR2
         CLC   FLAGWH,=H'2'
         BE    OTHER1
         L     R2,HADDR3
         CLC   FLAGWH,=H'3'
         BE    OTHER1
         L     R2,HADDR4
         CLC   FLAGWH,=H'4'
         BE    OTHER1
         L     R2,HADDR5
         CLC   FLAGWH,=H'5'
         BE    OTHER1
         L     R2,HADDR6
OTHER1   L     R1,ADDRESS2     POINT TO STORAGE
         A     R1,WIDTH
         AH    R1,=H'1'        START OF SCREEN WITHIN STORAGE
         L     R3,WIDTH        WIDTH OF SCREEN
         CH    R3,=H'80'       COMPARE TO HELP WIDTH
         BL    NEXT111         LOW? IF SO, TRUNCATE MOVE OPERATION
         LH    R3,=H'80'       NO; 80 BYTE MOVE OPERATION
NEXT111  BCTR  R3,R0           DECREMENT FOR EXEC
         L     R5,LIMH1
         CLC   FLAGWH,=H'1'
         BE    OTHER2
         L     R5,LIMH2
         CLC   FLAGWH,=H'2'
         BE    OTHER2
         L     R5,LIMH3
         CLC   FLAGWH,=H'3'
         BE    OTHER2
         L     R5,LIMH4
         CLC   FLAGWH,=H'4'
         BE    OTHER2
         L     R5,LIMH5
         CLC   FLAGWH,=H'5'
         BE    OTHER2
         L     R5,LIMH6
OTHER2   C     R5,DEPTH        COMPARE TO SCREEN DEPTH
         BL    LOOPH           LOW? IF SO, FULL HELP SCREEN
         L     R5,DEPTH        NO; SCREEN DEPTH SHORTENS HELP SCREEN
LOOPH    EX    R3,MOVEIT3      MOVE A ROW
         A     R1,WIDTH        INCREMENT TO NEXT ROW
         LA    R2,80(,R2)      INCREMENT TO NEXT HELP ROW
         BCT   R5,LOOPH        DECREMENT EFFECTIVE SCREEN DEPTH
         L     R1,ADDRESS2     FINISHED; TPUT IT AS WE NORMALLY DO
         A     R1,WIDTH
         SH    R1,=H'5'
         MVC   0(7,R1),FIELD2  HI INTENSITY PROTECTED
         ICM   R1,8,PUTR1      ADJUST HIGH ORDER BYTE FOR TPUT
         L     R0,LENGTH3      LENGTH
         SR    R15,R15         CLEAR
         TPUT  (1),(0),R       PUT IT
*        LTR   R15,R15         OK?
*        BNZ   ERROR9          NO; OUT
         L     R1,ADDRESS2
         A     R1,WIDTH
         SH    R1,=H'2'        FETCH A RESPONSE
         LR    R2,R1
         ICM   R1,8,GETR1
         L     R0,LENGTHG      LENGTH
         TGET  (1),(0),R       GET IT
*        LTR   R15,R15         OK?
*        BNZ   ERROR9          NO; OUT
         NI    0(R2),X'0F'
         CLI   0(R2),X'00'     INTERRUPT
         BNE   SKIP15
         STFSMODE ON,INITIAL=YES
         B     RESHOW
SKIP15   CLI   0(R2),X'07'     SCROLL UP?
         BNE   TRY1
         LH    R6,FLAGWH
         BCTR  R6,R0
         LTR   R6,R6
         BZ    RESHOW
         STH   R6,FLAGWH
         B     RESHOW
TRY1     CLI   0(R2),X'08'     SCROLL DOWN?
         BNE   TRY2
         LH    R6,FLAGWH
         LA    R6,1(,R6)
         CH    R6,=H'6'
         BH    RESHOW
         STH   R6,FLAGWH
         B     RESHOW
TRY2     SR    R6,R6
         LA    R6,2(,R6)
         STH   R6,FLAGWH
         L     R11,ADDRESS2
         LTR   R11,R11         GETMAIN PRESENT?
         BZ    DISPLAY2        NO; DISPLAY COLONY
         L     R1,STORAGE      YES; FREE STORAGE
         FREEMAIN R,A=(11),LV=(1)
         B     DISPLAY2        DISPLAY COLONY
RESTORE  CLI   FLAGDS,X'00'
         BE    ERROR17
         CLI   FLAGNODA,X'01'
         BE    ERROR15         IF NO INPUT DSET MESSAGE DISPLAY
         MVI   PHSDD+50,X'00'  CHANGE FROM GET LOCATE TO PUT LOCATE
         MVI   PHSDD+51,X'48'  CHANGE
         OPEN  (PHSDD,(OUTPUT))
         TM    PHSDD+48,X'10'  OPEN OK?
         BNO   ERROR3          NO, ERROR
         L     R2,ADDRESS
         A     R2,WIDTH
         AH    R2,=H'1'        START OF SCREEN
         L     R3,WIDTH        WIDTH
         CH    R3,PHSDD+82     COMPARE TO RECORD LENGTH
         BL    DOIT2           IF LOW, SCREEN WIDTH PREVAILS
         LH    R3,PHSDD+82     IF HIGH, RECORD LENGTH PREVAILS
DOIT2    BCTR  R3,R0           DECREMENT FOR EXEC
GETIT2   PUT   PHSDD           PUT BUFFER AND/OR GET BUFFER POINTER
         EX    R3,MOVEIT3      MOVE SCREEN ROW TO BUFFER ROW
         A     R2,WIDTH        INCREMENT TO NEXT ROW
         C     R2,LIMIT        SCREEN END?
         BL    GETIT2          NO; NEXT ROW
         CLOSE (PHSDD)         YES; CLOSE DATA SET
         CLI   FLAGNEWM,X'01'
         BNE   SKIP921
         L     R3,ADDRESS3
LOOPV1   CLC   MEMBER(8),0(R3)
         BL    INSERT
         LA    R3,8(,R3)
         C     R3,ADDRESS4
         BNH   LOOPV1
         MVC   TEMPMEM(8),MEMBER
         B     ENDITPRE
INSERT   MVC   TEMPMEM(8),0(R3)
         MVC   0(8,R3),MEMBER
         MVI   FLAGMEM,X'01'
         LA    R3,8(,R3)
         C     R3,ADDRESS4
         BH    ENDITPRE
LOOPV2   MVC   TEMPME2(8),0(R3)
         MVC   0(8,R3),TEMPMEM
         MVC   TEMPMEM(8),TEMPME2
         LA    R3,8(,R3)
         C     R3,ADDRESS4
         BNH   LOOPV2
ENDITPRE C     R3,ADDRESS6
         BNL   ENDITALL
         MVC   0(8,R3),TEMPMEM
         ST    R3,ADDRESS4
ENDITALL MVI   FLAGNEWM,X'00'
SKIP921  MVI   PHSDD+50,X'48'  RESTORE TO GET LOCATE
         MVI   PHSDD+51,X'00'  RESTORE
         B     DISPLAY2        DISPLAY COLONY
ROTATE   L     R1,STORAGE      TOTAL NUMBER OF BYTES FOR THE DISPLAY
         GETMAIN  R,LV=(1)
         ST    R1,ADDRESS2     GET STORAGE FOR MANIPULATION
         L     R4,ADDRESS
         A     R4,WIDTH
         LA    R4,1(,R4)       START OF SCREEN
         L     R2,ADDRESS2     STORAGE ADDRESS
         L     R3,STORAGE
         S     R3,WIDTH
         S     R3,WIDTH        TOTAL SCREEN LENGTH
         LR    R5,R3
         MVCL  R2,R4           MOVE SCREEN TO STORAGE AREA
         L     R4,ADDRESS
         A     R4,WIDTH
         LA    R4,1(,R4)       SCREEN START
         SR    R2,R2           CLEAR
         L     R3,WIDTH
         S     R3,DEPTH        WIDTH-DEPTH.....
         LH    R6,=H'2'
         DR    R2,R6           DIVIDED BY 2 GIVES FLANK SIZE
         LR    R7,R2           R7 IS REMAINDER
         LR    R2,R4
         SR    R2,R7           R2 IS FIRST ROW - REM
         SR    R2,R3           R2 IS FRIST ROW - FLANK - REM
         AR    R4,R3           R4 IS SCREEN START + FLANK
         A     R2,WIDTH        R2 IS END(FIRST ROW)-FLANK-REM
         BCTR  R2,R0           DECREMENT
         LR    R6,R2           R6<-R2
         L     R1,ADDRESS2     STORAGE AREA START
         L     R5,DEPTH        SCREEN DEPTH
         AR    R1,R3           STORAGE AREA + FLANK
LOOPV    MVC   0(1,R2),0(R1)   MOVE A BYTE FROM STORAGE TO SCREEN
         A     R2,WIDTH        NEXT BYTE OF COLUMN IN SCREEN AREA
         LA    R1,1(,R1)       NEXT BYTE OF ROW IN STORAGE AREA
         BCT   R5,LOOPV        DECREMENT UNTIL SCREEN BOTTOM
         BCTR  R6,R0           DECREMENT R6
         LR    R2,R6           PREV COLUMN BEGINNING
         A     R1,WIDTH        NEXT SUB-ROW IN STORAGE
         S     R1,DEPTH        NEXT ROW - MIDDLE PART
         L     R5,DEPTH        REFRESH DEPTH COUNTER
         CR    R6,R4           SCREEN END?
         BNL   LOOPV           NO; AGAIN
         L     R11,ADDRESS2    YES; FREE STORAGE IF THERE IS SOME
         LTR   R11,R11
         BZ    DISPLAY2
         L     R1,STORAGE
         FREEMAIN R,A=(11),LV=(1)
         B     DISPLAY2        DISPLAY COLONY
ERROR1   L     R2,ERR1AD
         B     WRITE                  GO AND WRITE IT
ERROR2   L     R2,ERR2AD
         B     WRITE
ERROR3   L     R2,ERR3AD
         B     WRITE                  GO AND WRITE IT
ERROR4   L     R2,ERR4AD
         B     WRITE
ERROR5   L     R2,ERR5AD
         B     WRITE                  GO AND WRITE IT
ERROR6   L     R2,ERR6AD
         B     WRITE
ERROR7   L     R2,ERR7AD
         B     WRITE                  GO AND WRITE IT
ERROR8   L     R2,ERR8AD
         B     WRITE                  GO AND WRITE IT
ERROR9   L     R2,ERR9AD
         B     WRITE                  GO AND WRITE IT
ERROR10  L     R2,ERR10AD
         B     WRITE                  GO AND WRITE IT
ERROR11  L     R2,ERR11AD
         B     WRITE                  GO AND WRITE IT
ERROR12  L     R2,ERR12AD
         B     WRITE                  GO AND WRITE IT
ERROR14  L     R2,ERR14AD
         B     WRITE                  GO AND WRITE IT
ERROR15  L     R2,ERR15AD
         B     WRITE                  GO AND WRITE IT
ERROR16  L     R2,ERR16AD
         B     WRITE                  GO AND WRITE IT
ERROR17  L     R2,ERR17AD
         B     WRITE                  GO AND WRITE IT
ERROR18  L     R2,ERR18AD
         B     WRITE                  GO AND WRITE IT
ERROR19  L     R2,ERR19AD
WRITE    L     R3,OUTADDR
         MVC   0(1,R3),BLNKS
         MVC   1(79,R3),0(R3)         CLEAR
         MVC   0(55,R3),0(R2)
         CLI   FLAGERRF,X'01'
         BNE   SKIP882
FULLERR  L     R1,STORAGE      TOTAL NUMBER OF BYTES FOR THE DISPLAY
         GETMAIN  R,LV=(1)
         ST    R1,ADDRESS5     BEGINNING OF HELP DISPLAY AREA
         LA    R4,BLNKS        CLEAR THE STORAGE GAINED
         LR    R2,R1
         L     R3,STORAGE
         L     R5,PADDING
         MVCL  R2,R4           FILL GETMAINED AREA WITH PAD OF BLANK
         L     R2,IADDR        POINT TO HELP INFORMATION
         L     R1,ADDRESS5     POINT TO STORAGE
         A     R1,WIDTH
         AH    R1,=H'1'        START OF SCREEN WITHIN STORAGE
         L     R3,WIDTH        WIDTH OF SCREEN
         SH    R3,=H'2'
         CH    R3,=H'54'       COMPARE TO ERR WIDTH
         BL    NEXT332         LOW? IF SO, TRUNCATE MOVE OPERATION
         LH    R3,=H'54'       NO; 55 BYTE MOVE OPERATION
NEXT332  BCTR  R3,R0           DECREMENT FOR EXEC
         L     R2,OUTADDR
         L     R5,LIMEF        HELP DEPTH
         C     R5,DEPTH        COMPARE TO SCREEN DEPTH
         BL    LOOPHX          LOW? IF SO, FULL HELP SCREEN
         L     R5,DEPTH        NO; SCREEN DEPTH SHORTENS HELP SCREEN
LOOPHX   EX    R3,MOVEIT14     MOVE A ROW
         A     R1,WIDTH        INCREMENT TO NEXT ROW
         L     R2,ERR99AD
         BCTR  R5,R0
         LTR   R5,R5
         BZ    RESHOW4
LOOPHY   EX    R3,MOVEIT14     MOVE A ROW
RESHOW4  L     R1,ADDRESS5     FINISHED; TPUT IT AS WE NORMALLY DO
         A     R1,WIDTH
         SH    R1,=H'5'
         MVC   0(7,R1),FIELD2  HI INTENSITY PROTECTED
         ICM   R1,8,PUTR1      ADJUST HIGH ORDER BYTE FOR TPUT
         L     R0,LENGTH3      LENGTH
         SR    R15,R15         CLEAR
         TPUT  (1),(0),R       PUT IT
*        LTR   R15,R15         OK?
*        BNZ   ERROR9          NO; OUT
         L     R1,ADDRESS5
         A     R1,WIDTH
         SH    R1,=H'2'        FETCH A RESPONSE
         LR    R2,R1
         ICM   R1,8,GETR1
         L     R0,LENGTHG      LENGTH
         TGET  (1),(0),R       GET IT
*        LTR   R15,R15         OK?
*        BNZ   ERROR9          NO; OUT
         NI    0(R2),X'0F'
         CLI   0(R2),X'00'     INTERRUPT
         BNE   SKIP144
         STFSMODE ON,INITIAL=YES
         B     RESHOW4
SKIP144  CLI   0(R2),X'03'
         BE    RETURN
         L     R11,ADDRESS5
         LTR   R11,R11         GETMAIN PRESENT?
         BZ    ENDFULLE        NO; DISPLAY COLONY
         L     R1,STORAGE      YES; FREE STORAGE
         FREEMAIN R,A=(11),LV=(1)
ENDFULLE SR    R6,R6
         ST    R6,GENREAL
         MVI   FLAGNO,X'00'
         CLI   FLAGRAW,X'01'
         BE    DISPLAY
         B     DISPLAY2
SKIP882  LH    R0,=H'80'             LINE LENGTH
         L     R1,OUTADDR            HIGH 2 BYTES R0 0 = NO ASID
         TPUT  (1),(0),R             HIGH R1 BYTE 0 = 'EDIT'
         B     RETURN
         L     R15,=F'00'
RETURN   SR    R15,R15               RESET R15
         STFSMODE OFF
         L     R5,DAPARMSA           ESTABLISH ADDRESSABILITY
         USING DAPL,R5
         L     R6,DAFREEA            ESTABLISH ADDRESSABILITY
         USING DAPB18,R6
         ST    R6,DAPLDAPB
         XC    0(44,R6),0(R6)        CLEAR PARM AREA
         MVI   DA18CD+1,X'18'        SET CODE TO DEALLOCATE
         MVC   DA18DDN,INPDD         MOVE IN DDNAME USED BY SYSTEM
         LA    R1,DAPL               POINT TO PARM LIST
         LINK  EP=IKJDAIR,MF=(E,(1)) DEALLOC
         L     R11,ADDRESS     FREE STORAGE IF THERE IS SOME
         LTR   R11,R11
         BZ    NOFREE
         L     R1,STORAGE
         FREEMAIN R,A=(11),LV=(1)
NOFREE   L     13,SAVE+4
         L     14,12(13)
         LM    0,12,20(13)
         BR    14              RETURN TO INVOKER
ATTN     LR    R2,R15
         USING ATTN,R2
         MVI   FLAGIN,X'01'
         BR    R14
         DROP  R2
ATT2     BR    14              RETURN TO INVOKER
OPERS    IKJPARM
OPER1    IKJPOSIT DSNAME,USID,DEFAULT='''Z7999999'''
         IKJENDP
*
* CONSTANTS
*
SAVE     DS    18F             LOCAL SAVE AREA
PACKAREA DS    D
PACK     PACK  PACKAREA,0(0,R4)
MOVEIT   MVC   0(0,R7),0(R9)        FOR MOVING DSNAME PARM
MOVEIT2  MVC   0(0,R2),0(R1)        FOR MOVING RECORDS IN
MOVEIT3  MVC   0(0,R1),0(R2)        FOR MOVING RECORDS OUT
MOVEIT4  MVC   0(0,R9),BLNKS
MOVEIT5  MVC   0(0,R1),0(R3)
MOVEIT6  MVC   0(0,R3),0(R2)
MOVEIT8  MVC   0(0,R5),BLNKS
MOVEIT9  MVC   TEMPAREA(0),0(R4)
MOVEIT10 MVC   MEMBER(0),2(R9)
MOVEIT11 MVC   5(0,R1),0(R2)        FOR MOVING RECORDS OUT
MOVEIT12 MVC   1(0,R1),0(R6)        FOR MOVING RECORDS OUT
MOVEIT14 MVC   2(0,R1),0(R2)        FOR MOVING RECORDS OUT
ORIT7    OC    0(0,R5),BLNKS
TRANIT   TR    0(0,R2),NUMBERS2
TEMPHALF DC    H'0'
INTCH    DC    CL8'1'
TMECH    DC    CL8'0'
GENCH    DC    CL8'0'
PAUCH    DC    CL8'0'
MO1CH    DC    CL8'6'
MO2CH    DC    CL8'20'
LIMCH    DC    CL8'10'
INT      DC    F'1'            ALL THE FOLLOWING ARE OBVIOUS
TME      DC    F'0'
GEN      DC    F'0'
PAU      DC    F'0'
MO1      DC    F'4'
MO2      DC    F'20'
LIM      DC    F'10'
INTREAL  DC    F'1'
TMEREAL  DC    F'0'
GENREAL  DC    F'0'
PAUREAL  DC    F'0'
GENCUR   DC    F'0'
GENABS   DC    F'0'
ADDRESS  DC    F'0'
ADDRESS2 DC    F'0'
ADDRESS3 DC    F'0'           GETMAIN ADDRESS FOR PDS DIRECTORY
ADDRESS4 DC    F'0'
ADDRESS5 DC    F'0'
ADDRESS6 DC    F'0'
ERR1AD   DC    A(ERR1)
ERR2AD   DC    A(ERR2)
ERR3AD   DC    A(ERR3)
ERR4AD   DC    A(ERR4)
ERR5AD   DC    A(ERR5)
ERR6AD   DC    A(ERR6)
ERR7AD   DC    A(ERR7)
ERR8AD   DC    A(ERR8)
ERR9AD   DC    A(ERR9)
ERR10AD  DC    A(ERR10)
ERR11AD  DC    A(ERR11)
ERR12AD  DC    A(ERR12)
ERR14AD  DC    A(ERR14)
ERR15AD  DC    A(ERR15)
ERR16AD  DC    A(ERR16)
ERR17AD  DC    A(ERR17)
ERR18AD  DC    A(ERR18)
ERR19AD  DC    A(ERR19)
ERR99AD  DC    A(ERR99)
HADDR1   DC    A(HELP1)
HADDR2   DC    A(HELP2)
HADDR3   DC    A(HELP3)
HADDR4   DC    A(HELP4)
HADDR5   DC    A(HELP5)
HADDR6   DC    A(HELP6)
IADDR    DC    A(INFOSCR)
MENUT    DC    A(MENUTIT)
OUTADDR  DC    A(OUTLINE)
ECBADDR  DC    A(ECB)
DAPARMSA DC    A(DAPARMS)
DAFREEA  DC    A(DAFREE)
DAALLOA  DC    A(DAALLOC)
ATTNA    DC    A(ATTNLST)
ATTNA2   DC    A(ATTNLS2)
DIRARAD  DC    A(DIRAREA)
TEMPDAAD DC    A(TEMPDATA)
STORAGE  DC    F'0'
STORAGE2 DC    F'0'
WIDTH    DC    F'0'
DEPTH    DC    F'0'
LIMIT    DC    F'0'
LIMH1    DC    F'24'           DEPTH OF HELP SCREEN
LIMH2    DC    F'24'
LIMH3    DC    F'24'
LIMH4    DC    F'24'
LIMH5    DC    F'24'
LIMH6    DC    F'24'
LIMI     DC    F'8'            DEPTH OF STATUS SCREEN
LIMEF    DC    F'3'            DEPTH OF STATUS SCREEN
TEMP     DC    F'0'
SHIFT1   DC    F'0'
SHIFT2   DC    F'0'
LENGTH   DC    F'0'
LENGTH2  DC    F'0'
LENGTH3  DC    F'0'
LENGTHG  DC    F'0'
LENGTHD  DC    F'10000'
LENGTHG2 DC    F'16'
DIRPTR   DC    F'0'
POPLAST  DC    F'0'
POPCUR   DC    F'0'
TEMPAREA DC    CL8'        '
PADDING  DC    X'40000008'     PAD AND LENGTH OF 'BLANKS'
DSORG    DC    X'00'
NUMBERS  DC    240XL1'01'
         DC    XL10'00'
         DC    6XL1'01'
NUMBERS2 DC    253XL1'40'
         DC    X'FF40FF'
         DS    0F
PATTGEN  DC    XL8'4020202020202120'
PUTR1    DC    X'1B'
GETR1    DC    X'81'
FIELD    DC    X'4011404013'
FIELD2   DC    X'40114040131DF8'   HI
FIELD3   DC    X'40114040131DF4'   LO
FIELD4   DC    X'4011404113114040'
PREF     DC    X'1D88401DF8'
PREF2    DC    X'1DF0401DF0'
PREF3    DC    X'1DF8'
         DS    0D
INPDD    DC    CL8' '          DDNAME GENERATED BY THE SYSTEM
DSNAME   DC    X'0000'         IKJDAIR DSNAME AREA..2 BYTE LENGTH
INFILE   DC    CL44' '                 PLUS DSNAME
MEMBER   DC    CL8' '          MEMBER FIELD FOR IKJPARS
TEMPMEM  DC    CL8' '
TEMPME2  DC    CL8' '
BLNKS    DC    CL44' '
         DS    F
PPL      DS    0F              PPL AREA
PPLUPT   DS    F
PPLECT   DS    F
PPLECB   DS    A(PARMECB)
PPLPCL   DC    V(OPERS)
PPLANS   DC    A(PDLPTR)
PPLCBUF  DS    F
PPLVWA   DC    F'0'
PARMECB  DC    F'0'
PDLPTR   DS    F
ACCUM    DC    F'0'
ACCUM2   DC    F'0'
CHAR     DC    C'*'
OLDCHAR  DC    X'11'
EXCHAR   DC    C'*'
XXCHAR   DC    C'*'
FLAG     DC    C'N'
FLAGDIS  DC    X'00'
FLAGDIR  DC    X'00'
FLAGNO   DC    X'00'
FLAGDS   DC    X'01'
FLAGO    DC    X'00'
FLAGWH   DC    H'1'
FLAGIN   DC    X'00'
FLAGOK   DC    X'01'
FLAGNODA DC    X'00'
FLAGCL   DC    X'00'
FLAGTEMP DC    X'00'
FLAGTIME DC    X'00'
FLAGPDS  DC    X'00'
FLAGNEWM DC    X'00'
FLAGMEM  DC    X'00'
FLAGRAW  DC    X'00'
FLAGERRF DC    X'00'
FLAGSTAT DC    C'N'
         DS    0H
FINNAM   DC    8XL1'FF'        LAST MEMBER NAME
BYTECNT  DC    H'0'
PHSDD    DCB   MACRF=(GL),DSORG=PS,DDNAME=PHSDD,EODAD=ENDFIL,          *
               SYNAD=ERROR5,BFTEK=E
PDSDD    DCB   MACRF=(R),DSORG=PS,DDNAME=PHSDD,EODAD=ENDFIL,RECFM=U,   *
               SYNAD=ERROR5
         LTORG
ATTNLST  STAX  ATTN,MF=L
ATTNLS2  STAX  ATT2,MF=L
TEMPDATA DC    CL12'        '
         DC    CL12'        '
         DC    CL12'        '
         DC    CL12'        '
DIRAREA  DS    CL256
ECB      DS    F               EVENT CONROL BLOCK
DAPARMS  DS    5A              IKJDAIR LIST
DAALLOC  DS    26F                     ....
DAFREE   DS    11F                     ....
OUTLINE  DS    CL80' '
ERR1     DC    CL55'L01:- LIFE MUST BE INVOKED AS A COMMAND PROCESSOR'
ERR2     DC    CL55'L02:- LIFE HAS SUFFERED A PARAMETER ERROR'
ERR3     DC    CL55'L03:- LIFE COULD NOT OPEN THE INPUT DATA SET'
ERR4     DC    CL55'L04:- LIFE HAS SUFFERED A CLOCK ERROR'
ERR5     DC    CL55'L05:- LIFE HAD A READ ERROR ON THE INPUT DATA SET'
ERR6     DC    CL55'L06:- LIFE WILL ONLY PROCESS FIXED LENGTH RECORDS'
ERR7     DC    CL55'L07:- LIFE COULD NOT ALLOCATE THE INPUT DATA SET'
ERR8     DC    CL55'L08:- LIFE WILL ONLY WORK ON FULL SCREEN DEVICES'
ERR9     DC    CL55'L09:- LIFE HAS SUFFERED A TPUT OR TGET ERROR'
ERR10    DC    CL55'L10:- THE INPUT DATASET HAS AN INVALID DSORG'
ERR11    DC    CL55'L11:- THE "EXIT" KEY WAS HIT'
ERR12    DC    CL55'L12:- THE INPUT PDS DIRECTORY IS EMPTY'
ERR14    DC    CL55'L14:- THE READ KEY IS DISABLED: NO INPUT DATA'
ERR15    DC    CL55'L14:- THE WRITE KEY IS DISABLED: NO DESTINATION'
ERR16    DC    CL55'L16:- LIFE COULD NOT ALLOCATE THE SPECIFIED MEMBER'
ERR17    DC    CL55'L17:- THE REQUESTED DATA SET OPTION IS DISABLED'
ERR18    DC    CL55'L18:- ATTENTION/INTERRUPT CONDITION DETECTED'
ERR19    DC    CL55'L19:- PDS DIRECTORY OVERFLOW: MENU TRUNCATED'
ERR99    DC    CL55'L99:- HIT "ENTER" TO RETURN OR "END" KEY TO EXIT'
MENUTIT  DC    CL40'++-----------------------LIFE PROGRAM SE'
         DC    CL40'LECTION MENU---------------------------+'
INFOSCR  DC    CL40'+------------------------LIFE PROGRAM ST'
         DC    CL40'ATUS SCREEN ---------------------------+'
         DC    CL40'|  Character=X  (Previously: Y)         '
         DC    CL40'|   Interval=12345678    Time=12345678 |'
         DC    CL40'| Current  Generation=                  '
         DC    CL40'|      Limit=           Stats=1        |'
         DC    CL40'| Absolute Generation=                  '
         DC    CL40'| Generation=12345678   Pause=12345678 |'
         DC    CL40'|          Population=                  '
         DC    CL40'| Scroll Ver=1            Hor=1        |'
         DC    CL40'+---------------------------------------'
         DC    CL40'+--------------------------------------+'
         DC    CL40'| Dsname=12345678.12345678.12345678.1234'
         DC    CL40'5678.12345678        Member=12345678   |'
         DC    CL40'+---------------------------------------'
         DC    CL40'---------------------------------------+'
HELP1    DC    CL40'+---------------------------------------'
         DC    CL40'---------------------------------------+'
         DC    CL40'|                                       '
         DC    CL40'                                       |'
         DC    CL40'|     WELCOME TO CONWAY''S GAME OF.......'
         DC    CL40'...                                    |'
         DC    CL40'|                                       '
         DC    CL40'                                       |'
         DC    CL40'|                                       '
         DC    CL40'                                       |'
         DC    CL40'|                                       '
         DC    CL40'                                       |'
         DC    CL40'|         LLLLL              IIIII     F'
         DC    CL40'FFFFFFFFFFFF     EEEEEEEEEEEEE         |'
         DC    CL40'|         LLLLL              IIIII     F'
         DC    CL40'FFFFFFFFFFFF     EEEEEEEEEEEEE         |'
         DC    CL40'|         LLLLL              IIIII     F'
         DC    CL40'FFFF             EEEEE                 |'
         DC    CL40'|         LLLLL              IIIII     F'
         DC    CL40'FFFFFFFF         EEEEEEEEE             |'
         DC    CL40'|         LLLLL              IIIII     F'
         DC    CL40'FFFF             EEEEE                 |'
         DC    CL40'|         LLLLLLLLLLLLLL     IIIII     F'
         DC    CL40'FFFF             EEEEEEEEEEEEE         |'
         DC    CL40'|         LLLLLLLLLLLLLL     IIIII     F'
         DC    CL40'FFFF             EEEEEEEEEEEEE         |'
         DC    CL40'|                                       '
         DC    CL40'                                       |'
         DC    CL40'|                                       '
         DC    CL40'                                       |'
         DC    CL40'|                                       '
         DC    CL40'                                       |'
         DC    CL40'|     SCROLL DOWN FOR FURTHER INFORMATIO'
         DC    CL40'N OR HIT ANY OTHER KEY TO GO           |'
         DC    CL40'|     DIRECTLY TO THE INPUT SCREEN FOR T'
         DC    CL40'HE FIRST GENERATION                    |'
         DC    CL40'|                                       '
         DC    CL40'                                       |'
         DC    CL40'|                                       '
         DC    CL40'                                       |'
         DC    CL40'|                                       '
         DC    CL40'                                       |'
         DC    CL40'|                                       '
         DC    CL40'                                       |'
         DC    CL40'|                                       '
         DC    CL40'                                       |'
         DC    CL40'+---------------------------------------'
         DC    CL40'---------------------------------------+'
HELP2    DC    CL40'+------------------------LIFE PROGRAM HE'
         DC    CL40'LP SCREEN----------------------PAGE 1--+'
         DC    CL40'|                                       '
         DC    CL40'                                       |'
         DC    CL40'| Life is a program which takes a set of'
         DC    CL40' characters (initially the default     |'
         DC    CL40'| character of "*") and uses these as re'
         DC    CL40'presentations of "cells". The "cells"  |'
         DC    CL40'| are then subjected to a process of evo'
         DC    CL40'lution based on the following          |'
         DC    CL40'| criteria:-                            '
         DC    CL40'                                       |'
         DC    CL40'|            1. A cell shall survive if '
         DC    CL40'it has at least two neighbours but     |'
         DC    CL40'|               no more than three neigh'
         DC    CL40'bours, otherwise the existent cell     |'
         DC    CL40'|               shall die.              '
         DC    CL40'                                       |'
         DC    CL40'|            2. A cell shall be born on '
         DC    CL40'an unoccupied location if that location|'
         DC    CL40'|               has exactly three neighb'
         DC    CL40'ours.                                  |'
         DC    CL40'|                                       '
         DC    CL40'                                       |'
         DC    CL40'| A neighbouring location is any of the '
         DC    CL40'eight possible locations surrounding   |'
         DC    CL40'| a square on a grid.                   '
         DC    CL40'                                       |'
         DC    CL40'| The above scheme serves to create a we'
         DC    CL40'll balanced ecology which ultimately   |'
         DC    CL40'| stabilises or dies out, a process whic'
         DC    CL40'h can extend for thousands of          |'
         DC    CL40'| generations (a generation being one ap'
         DC    CL40'plication of the rules to the entire   |'
         DC    CL40'| colony simultaneously). The user, in t'
         DC    CL40'his application, has control over      |'
         DC    CL40'| the initial colony shape, the number o'
         DC    CL40'f generations to run it and so on.     |'
         DC    CL40'|                                       '
         DC    CL40'                                       |'
         DC    CL40'|                                       '
         DC    CL40'                                       |'
         DC    CL40'|                                       '
         DC    CL40'                                       |'
         DC    CL40'|                                       '
         DC    CL40'                                       |'
         DC    CL40'+----SCROLL DOWN FOR INSTRUCTIONS-------'
         DC    CL40'---------------------------------------+'
HELP3    DC    CL40'+------------------------LIFE PROGRAM HE'
         DC    CL40'LP SCREEN----------------------PAGE 2--+'
         DC    CL40'|                                       '
         DC    CL40'                                       |'
         DC    CL40'| Command Format: "LIFE DSNAME"      (Ds'
         DC    CL40'name is optional)                      |'
         DC    CL40'|                                       '
         DC    CL40'                                       |'
         DC    CL40'| After invocation, the user will, after'
         DC    CL40' leaving this help section, be         |'
         DC    CL40'| presented with a blank screen; this is'
         DC    CL40' the first generation base which may   |'
         DC    CL40'| be edited and set going. Editing consi'
         DC    CL40'sts of placing a collection of cells   |'
         DC    CL40'| on the screen (initially represented b'
         DC    CL40'y "*") and then specifying a "g"       |'
         DC    CL40'| greater than zero to process it. Other'
         DC    CL40' options may be altered at leisure     |'
         DC    CL40'| between generation cycles. If a data s'
         DC    CL40'et was specified, then the data may    |'
         DC    CL40'| be mapped onto the screen with the rea'
         DC    CL40'd key, or saved at any time with the   |'
         DC    CL40'| the write key. If the data set is a pd'
         DC    CL40's, a member must first be specified    |'
         DC    CL40'| with the "M=" option; alternatively, a'
         DC    CL40' member list may be displayed with the |'
         DC    CL40'| "D=" option whereby one can select a m'
         DC    CL40'ember by placing any character before  |'
         DC    CL40'| the desired member name and hitting "E'
         DC    CL40'nter". Only the Scroll Up/Down keys    |'
         DC    CL40'| are functional in the menu display. On'
         DC    CL40'e may also deallocate a PDS member by  |'
         DC    CL40'| specifying "M= ",  thereby protecting '
         DC    CL40'it from further "Writes". If upon      |'
         DC    CL40'| invocation the display is distorted du'
         DC    CL40'e to a disparity between the display   |'
         DC    CL40'| size and the screen size, then the int'
         DC    CL40'errupt key will rectify this anomaly.  |'
         DC    CL40'| The interrupt key may also be used to '
         DC    CL40'prematurely end a generation cycle.    |'
         DC    CL40'| Non standard screen sizes (i.e. those '
         DC    CL40'which do not reflect the actual        |'
         DC    CL40'| display screen size) may cause data tr'
         DC    CL40'ansmission errors.                     |'
         DC    CL40'|                                       '
         DC    CL40'                                       |'
         DC    CL40'+----SCROLL UP FOR THE INTRODUCTION--SCR'
         DC    CL40'OLL DOWN FOR FURTHER NOTES-------------+'
HELP4    DC    CL40'+------------------------LIFE PROGRAM HE'
         DC    CL40'LP SCREEN----------------------PAGE 3--+'
         DC    CL40'|                                       '
         DC    CL40'                                       |'
         DC    CL40'| The screen wraps around in both direct'
         DC    CL40'ions and thus represents a torus, a    |'
         DC    CL40'| shape which contains the colony withou'
         DC    CL40't pruning the bounds. One must beware, |'
         DC    CL40'| though, of using samples on different '
         DC    CL40'screen sizes: the destiny varies by    |'
         DC    CL40'| virtue of the edge interactions. It is'
         DC    CL40' best to have a sample library for     |'
         DC    CL40'| each device type.                     '
         DC    CL40'                                       |'
         DC    CL40'| Some facts: specifying "C= " clears th'
         DC    CL40'e screen; when a new character is      |'
         DC    CL40'| specified, all occurrences of both the'
         DC    CL40' old character and the new character   |'
         DC    CL40'| qualify for the next generation; the "'
         DC    CL40'I=" option  is overridden by the "G="  |'
         DC    CL40'| option, thus if "G" is 10 and "I" is 4'
         DC    CL40', then one will get an image update at |'
         DC    CL40'| generations 4, 8 and finally 10. "L" o'
         DC    CL40'verrides "G" and a similar scenario is |'
         DC    CL40'| possible. "L" actually states that if '
         DC    CL40'the population stabilises, "L"         |'
         DC    CL40'| generations will be processed before t'
         DC    CL40'he cycle stops. If the population      |'
         DC    CL40'| reaches zero, "L" is always zero. The '
         DC    CL40'reason "L" is available is that a      |'
         DC    CL40'| population may be stable without havin'
         DC    CL40'g truly stabilised, a fact which will  |'
         DC    CL40'| become apparent after some use of the '
         DC    CL40'program.                               |'
         DC    CL40'| The pause and time options are useful '
         DC    CL40'when one wishes to dwell awhile on     |'
         DC    CL40'| each generation, or if the terminal im'
         DC    CL40'age refreshes too quickly for the      |'
         DC    CL40'| eye to see it. Also, I would recommend'
         DC    CL40' the use of a channel attached         |'
         DC    CL40'| terminal; the graphics can be remarkab'
         DC    CL40'le because of the speed.               |'
         DC    CL40'| One last point: the program is very fa'
         DC    CL40'st, so beware of resource usage; the   |'
         DC    CL40'| "T" option can be useful here.        '
         DC    CL40'                                       |'
         DC    CL40'+----SCROLL DOWN FOR THE COMMAND LIST--S'
         DC    CL40'CROLL UP FOR PREVIOUS NOTES------------+'
HELP5    DC    CL40'+------------------------LIFE PROGRAM HE'
         DC    CL40'LP SCREEN----------------------PAGE 4--+'
         DC    CL40'|Commands: (which may be entered indepen'
         DC    CL40'dently anywhere on the life screen)    |'
         DC    CL40'|                                       '
         DC    CL40'                                       |'
         DC    CL40'|G=0-9999999; The number of generations '
         DC    CL40'processed between terminal inputs.     |'
         DC    CL40'|I=0-9999999; The number of generations '
         DC    CL40'processed between screen image updates.|'
         DC    CL40'|P=0-9999999; The program wait time in 1'
         DC    CL40'/100ths Sec between image updates.     |'
         DC    CL40'|T=0-9999999; The program wait time in 1'
         DC    CL40'/100ths Sec between generations.       |'
         DC    CL40'|D=         ; Displays the directory of '
         DC    CL40'the dataset if it is partitioned.      |'
         DC    CL40'|R=         ; Resets the current generat'
         DC    CL40'ion counter to zero.                   |'
         DC    CL40'|S=Y or N   ; Specify y for execution ti'
         DC    CL40'me statistics display.                 |'
         DC    CL40'|C=         ; Any character which will b'
         DC    CL40'e used to represent the cells.         |'
         DC    CL40'|M=Member   ; If a PDS was specified, a '
         DC    CL40'new member to display on the screen.   |'
         DC    CL40'|H=0-Width  ; Number of columns used wit'
         DC    CL40'h the Scroll Left/Right key            |'
         DC    CL40'|V=0-Depth  ; Number of rows    used wit'
         DC    CL40'h the Scroll Up/Down    key            |'
         DC    CL40'|             Defaults: G=0, I=1, P=0, T'
         DC    CL40'=0, V=6, H=20, C=*, S=Y.               |'
         DC    CL40'|Pf keys:                               '
         DC    CL40'                                       |'
         DC    CL40'|PFK1/13  Help Screen    ; PFK2/14  Cent'
         DC    CL40're colony ; PFK3/15  End the session   |'
         DC    CL40'|PFK4/16  Read data      ; PFK5/17  Writ'
         DC    CL40'e data    ; PFK6/18  Reflect left-right|'
         DC    CL40'|PFK7/19  Scroll up      ; PFK8/20  Scro'
         DC    CL40'll down   ; PFK9/21  Reflect up-down   |'
         DC    CL40'|PFK10/22 Scroll left    ; PFK11/23 Scro'
         DC    CL40'll right  ; PFK12/24 Rotate middle     |'
         DC    CL40'|PA2      Display status ; PA1/ATTN Inte'
         DC    CL40'rrupt     ;                            |'
         DC    CL40'|PFK4/16 and PFK5/17 refer to the Data S'
         DC    CL40'et option of the Life command.         |'
         DC    CL40'|                                       '
         DC    CL40'                                       |'
         DC    CL40'+----SCROLL UP FOR THE INSTRUCTIONS--SCR'
         DC    CL40'OLL DOWN FOR ADVANCED TOPICS-----------+'
HELP6    DC    CL40'+------------------------LIFE PROGRAM HE'
         DC    CL40'LP SCREEN----------------------PAGE 5--+'
         DC    CL40'|  Advanced Topics                      '
         DC    CL40'                                       |'
         DC    CL40'|                                       '
         DC    CL40'                                       |'
         DC    CL40'|  If one specifies a new value of "V=" '
         DC    CL40'or "H=" (scrolling) or "M="  (member)  |'
         DC    CL40'|  then the screen will be presented aga'
         DC    CL40'in to the user even if "G" > 0; this   |'
         DC    CL40'|  is done because these three options a'
         DC    CL40're not execution time options and thus |'
         DC    CL40'|  should not be allowed to trigger the '
         DC    CL40'process, even though other run time    |'
         DC    CL40'|  options may have been specified.     '
         DC    CL40'                                       |'
         DC    CL40'|  When one saves a screen of data by hi'
         DC    CL40'tting the "Write" Pf key, it is        |'
         DC    CL40'|  possible to embed options in the data'
         DC    CL40' before saving the data. The effect of |'
         DC    CL40'|  this is that when the data is used la'
         DC    CL40'ter as a sample, the options will      |'
         DC    CL40'|  already have been chosen (perhaps jud'
         DC    CL40'iciously?) and the user need only      |'
         DC    CL40'|  hit the enter key to set the sample g'
         DC    CL40'oing.                                  |'
         DC    CL40'|  If one wishes to save the current scr'
         DC    CL40'een, but without destroying the        |'
         DC    CL40'|  original member from which it came, t'
         DC    CL40'hen try the following:-                |'
         DC    CL40'|  Either  1. Enter "M=Newname" (no proc'
         DC    CL40'essing will be done) and then          |'
         DC    CL40'|             hit the "Write" key; the d'
         DC    CL40'ata will be stored in "Newname".       |'
         DC    CL40'|          2. Enter "D="; the Menu will '
         DC    CL40'be presented. select a new member and  |'
         DC    CL40'|             hit enter. Your original s'
         DC    CL40'creen will return, and you can now     |'
         DC    CL40'|             hit the "Write" key.      '
         DC    CL40'                                       |'
         DC    CL40'| To create a new member, simply use the'
         DC    CL40' "M=" option specifying a non-existent |'
         DC    CL40'| member name. The "Read" key will be te'
         DC    CL40'mporarily disabled until something is  |'
         DC    CL40'| written to it.                        '
         DC    CL40'                                       |'
         DC    CL40'+----SCROLL UP FOR THE COMMAND LIST-----'
         DC    CL40'---------------------------------------+'
INFODSC  DSECT ,
         DS    CL80
         DS    CL13
CHAR1X   DS    CL1
         DS    CL15
CHAR2X   DS    CL1
         DS    CL10
         DS    CL13
INT1X    DS    CL8
         DS    CL9
TME1X    DS    CL8
         DS    CL2
         DS    CL22
CGEN1X   DS    CL8
         DS    CL10
         DS    CL13
LIM1X    DS    CL8
         DS    CL9
SHO1X    DS    CL8
         DS    CL2
         DS    CL22
AGEN1X   DS    CL8
         DS    CL10
         DS    CL13
GEN1X    DS    CL8
         DS    CL9
PAU1X    DS    CL8
         DS    CL2
         DS    CL22
POP1X    DS    CL8
         DS    CL10
         DS    CL13
MOV1X    DS    CL8
         DS    CL9
MOV2X    DS    CL8
         DS    CL2
FILLER   DS    CL80
         DS    CL9
DSN1X    DS    CL44
         DS    CL15
MEM1X    DS    CL8
         DS    CL4
         IKJCPPL
         IKJDAPL
         IKJDAP08
         IKJDAP18
         CVT   DSECT=YES
         END   LIFE
//LKED.SYSLMOD DD DSN=SYS2.CMDLIB,DISP=SHR
//LKED.SYSIN DD *
 ENTRY   LIFE
 NAME    LIFE(R)
//