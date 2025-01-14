//DIVER   JOB (SYS),'INSTALL DIVER',CLASS=A,MSGCLASS=A,COND=(1,LT),
//        USER=IBMUSER,PASSWORD=SYS1
//* From CBT Tape 134
// EXEC ASMFCL,MAC='SYS1.AMODGEN',MAC1='SYS1.MACLIB',
//             PARM.ASM='LIST,XREF,OBJECT,NODECK',
//             PARM.LKED='XREF,LET,LIST,NCAL'
//ASM.SYSIN DD *
DIVER    CSECT
         TITLE 'THE DIVER OF XXXX'
*
*  PERFORM START HOUSEKEEPING FUNCTIONS
*
BEGIN    SAVE  (14,12)
         LR    11,15
         USING BEGIN,11
         ST    13,SAVEAREA+4
         LA    13,SAVEAREA
         EJECT
*
*  BEGIN PROGRAM CODE
*
          WTO     'THIS USER IS PLAYING A GAME',ROUTCDE=(2),DESC=(7)
          TPUT    CLRSCRN,CLREND,NOEDIT,WAIT   * INITIAL CLEAR SCREEN *
PART1     L       2,=X'00000000'               *  LOAD INDEX REGISTER *
          LA      5,0                          *   SETUP LOOP CONTROL *
          LA      4,1                          *                      *
          LA      6,1                          *                      *
          L       7,=X'00000032'               *           LOOP COUNT *
LOOPMAN   AR      5,4                          *           BEGIN LOOP *
          TPUT    SCRN1,SCRN1LEN,NOEDIT,WAIT   *                      *
          A       2,=X'00000002'               *                      *
          LA      8,LOC1                       *                      *
          BAL     12,MOVERMAN                  *                      *
          LA      8,LOC2                       *                      *
          BAL     12,MOVERMAN                  *                      *
          LA      8,LOC3                       *                      *
          BAL     12,MOVERMAN                  *                      *
          LA      8,LOC4                       *                      *
          BAL     12,MOVERMAN                  *                      *
          BXLE    4,6,LOOPMAN                  *             END LOOP *
          LA      6,COVER                      *                      *
          LH      5,=X'01BB'                   *                      *
          STH     5,1(6)                       *                      *
PART2     L       2,=X'00000000'               *  LOAD INDEX REGISTER *
          LA      5,0                          *   SETUP LOOP CONTROL *
          LA      4,1                          *                      *
          LA      6,1                          *                      *
          L       7,=F'19'                     *           LOOP COUNT *
LOOPPIS   AR      5,4                          *           BEGIN LOOP *
          TPUT    SCRN1,SCRN1LEN,NOEDIT,WAIT   *                      *
          A       2,=X'00000002'               *                      *
          LA      8,LOCPIS                     *                      *
          BAL     12,MOVERPIS                  *                      *
          BXLE    4,6,LOOPPIS                  *             END LOOP *
PART3     LA      6,POOLCOL                    *                      *
          LH      5,=X'42F6'                   *                      *
          STH     5,1(6)                       *                      *
          LA      5,0                          *   SETUP LOOP CONTROL *
          LA      4,1                          *                      *
          LA      6,1                          *                      *
          L       7,=F'27'                     *           LOOP COUNT *
COLORPOL  AR      5,4                          *           BEGIN LOOP *
          TPUT    SCRN1,SCRN1LEN,NOEDIT,WAIT   *                      *
          LA      8,PL1                        *                      *
          BAL     12,COLORPL                   *                      *
          LA      8,PL2                        *                      *
          BAL     12,COLORPL                   *                      *
          LA      8,PL3                        *                      *
          BAL     12,COLORPL                   *                      *
          BXLE    4,6,COLORPOL                 *             END LOOP *
          LA      6,COVER                      *                      *
          LH      5,=X'016B'                   *                      *
          STH     5,1(6)                       *                      *
          LA      6,LOCPIS                     *                      *
          L       5,=X'01BB0000'               *                      *
          ST      5,1(6)                       *                      *
PART4     L       2,=X'00000000'               *  LOAD INDEX REGISTER *
          LA      5,0                          *   SETUP LOOP CONTROL *
          LA      4,1                          *                      *
          LA      6,1                          *                      *
          L       7,=F'19'                     *           LOOP COUNT *
COVRPIS2  AR      5,4                          *           BEGIN LOOP *
          TPUT    SCRN1,SCRN1LEN,NOEDIT,WAIT   *                      *
          A       2,=X'00000002'               *                      *
          LA      8,LOCPIS                     *                      *
          BAL     12,MOVERPIS                  *                      *
          BXLE    4,6,COVRPIS2                 *             END LOOP *
*                                              *                      *
          EJECT                                *                      *
*                                              *                      *
*  PERFORM END HOUSEKEEPING FUNCTIONS          *                      *
*                                              *                      *
          L      13,SAVEAREA+4                 *                      *
          RETURN (14,12)                       *                      *
          EJECT                                *                      *
*                                              *                      *
*  PROGRAM SUBROUTINES                         *                      *
*                                              *                      *
MOVERMAN  LH      9,1(8)                       *                      *
          AH      9,DIRECT(2)                  *                      *
          STH     9,1(8)                       *                      *
          BR      12                           *                      *
MOVERPIS  LH      9,1(8)                       *                      *
          AH      9,DIRPIS(2)                  *                      *
          STH     9,1(8)                       *                      *
          BR      12                           *                      *
COLORPL   LH      9,1(8)                       *                      *
          AH      9,CLORPL                     *                      *
          STH     9,1(8)                       *                      *
          LH      9,4(8)                       *                      *
          AH      9,CLORPL2                    *                      *
          STH     9,4(8)                       *                      *
          BR      12                           *                      *
          EJECT                                *                      *
*                                              *                      *
*  PROGRAM DATA AREAS                          *                      *
*                                              *                      *
SAVEAREA DS    18F                             *                      *
DIRECT   DC   11H'-1'                          *                      *
         DC   17H'-80'                         *                      *
         DC   24H'-1'                          *                      *
DIRPIS   DC    1H'80'                          *                      *
         DC    1H'-2'                          *                      *
         DC    2H'-1'                          *                      *
         DC    1H'78'                          *                      *
         DC    1H'78'                          *                      *
         DC    1H'78'                          *                      *
         DC    3H'79'                          *                      *
         DC    1H'80'                          *                      *
         DC    2H'79'                          *                      *
         DC    1H'80'                          *                      *
         DC    1H'79'                          *                      *
         DC    8H'80'                          *                      *
CLORPL   DC     H'-1'                          *                      *
CLORPL2  DC     H'1'                           *                      *
BUFFER   DS    C                               *                      *
          EJECT
* ##################################################################
*
*      ##############    DEFINE DIVER DATA    ##############
*
* ##################################################################
SCRN1    DC    X'F1C3'               ERASE/WRITE
*
*   BUILD FULL SCREEN FRAME
*
   DCS   SA,COLOUR,RED,SF,UNPLO
   DCS   SBA,(01,1),X'08C5',RTA,(01,80),X'08A2',SBA,(01,80),X'08D5'
   DCS   SBA,(02,1),X'0885',SBA,(02,80),X'0885'
   DCS   SBA,(03,1),X'0885',SBA,(03,80),X'0885'
   DCS   SBA,(04,1),X'0885',SBA,(04,80),X'0885'
   DCS   SBA,(05,1),X'0885',SBA,(05,80),X'0885'
   DCS   SBA,(06,1),X'0885',SBA,(06,80),X'0885'
   DCS   SBA,(07,1),X'0885',SBA,(07,80),X'0885'
   DCS   SBA,(08,1),X'0885',SBA,(08,80),X'0885'
   DCS   SBA,(09,1),X'0885',SBA,(09,80),X'0885'
   DCS   SBA,(10,1),X'0885',SBA,(10,80),X'0885'
   DCS   SBA,(11,1),X'0885',SBA,(11,80),X'0885'
   DCS   SBA,(12,1),X'0885',SBA,(12,80),X'0885'
   DCS   SBA,(13,1),X'0885',SBA,(13,80),X'0885'
   DCS   SBA,(14,1),X'0885',SBA,(14,80),X'0885'
   DCS   SBA,(15,1),X'0885',SBA,(15,80),X'0885'
   DCS   SBA,(16,1),X'0885',SBA,(16,80),X'0885'
   DCS   SBA,(17,1),X'0885',SBA,(17,80),X'0885'
   DCS   SBA,(18,1),X'0885',SBA,(18,80),X'0885'
   DCS   SBA,(19,1),X'0885',SBA,(19,80),X'0885'
   DCS   SBA,(20,1),X'0885',SBA,(20,80),X'0885'
   DCS   SBA,(21,1),X'0885',SBA,(21,80),X'0885'
   DCS   SBA,(22,1),X'0885',SBA,(22,80),X'0885'
   DCS   SBA,(23,1),X'0885',SBA,(23,80),X'0885'
   DCS   SBA,(24,1),X'08C4',RTA,(24,80),X'08A2',SBA,(24,80),X'08D4'
*
*    DIVER BACKGROUND
*
   DCS   SA,COLOUR,BLUE
   DCS   SBA,(04,67),X'08D708A208D7'
   DCS   SBA,(05,67),X'0885'
   DCS   SBA,(05,69),X'0885'
   DCS   SBA,(06,67),X'0885'
   DCS   SBA,(06,69),X'0885'
   DCS   SBA,(07,67),X'0885'
   DCS   SBA,(07,69),X'0885'
*
*    BUILD DIVER
*
   DCS   SA,COLOUR,TURQ,SF,UNPLO
   DCS   SBA,(07,45),RTA,(07,55),X'0893'
   DCS   SA,COLOUR,BLUE
   DCS   SBA,(07,55),X'0895',RTA,(07,74),X'0895',SBA,(07,74),X'0891'
   DCS   SBA,(08,64),X'08C6',RTA,(08,72),X'4040',SBA,(08,72),X'08D6'
   DCS   SBA,(09,64),X'08C6',RTA,(09,72),X'4040',SBA,(09,72),X'08D6'
   DCS   SBA,(10,64),X'08C6',RTA,(10,72),X'4040',SBA,(10,72),X'08D6'
   DCS   SBA,(11,64),X'08C6',RTA,(11,72),X'4040',SBA,(11,72),X'08D6'
   DCS   SBA,(12,61),X'08C508A208D708C708D740',SBA,(12,71),X'08A208D6'
   DCS   SBA,(13,61),X'088540088540088540088540',SBA,(13,71),X'400885'
   DCS   SA,COLOUR,TURQ
   DCS   SBA,(14,55),RTA,(14,61),X'0893'
   DCS   SA,COLOUR,BLUE
   DCS   SBA,(14,61),X'0895',RTA,(14,72),X'0895',SBA,(14,72),X'0895'
   DCS   SBA,(15,64),X'08C6',RTA,(15,72),X'4040',SBA,(15,72),X'08D6'
   DCS   SBA,(16,64),X'08C6',RTA,(16,72),X'4040',SBA,(16,72),X'08D6'
   DCS   SBA,(17,64),X'08C6',RTA,(17,72),X'4040',SBA,(17,72),X'08D6'
   DCS   SBA,(18,64),X'08C6',RTA,(18,72),X'4040',SBA,(18,72),X'08D6'
   DCS   SBA,(19,63),X'08C508D4',SBA,(19,72),X'08C408D5'
   DCS   SBA,(20,63),X'08C6',RTA,(20,73),X'4040',SBA,(20,73),X'08D6'
   DCS   SBA,(21,62),X'08C508D4',SBA,(21,73),X'08C408D5'
   DCS   SBA,(22,62),X'08C6',RTA,(22,74),X'4040',SBA,(22,74),X'08D6'
   DCS   SBA,(23,62),X'08C6',RTA,(23,74),X'4040',SBA,(23,74),X'08D6'
*
*    INSERT LADDER
*
   DCS   SA,COLOUR,WHITE,SF,UNPLO
   DCS   SBA,(07,66),X'08C6',RTA,(07,70),X'08A2'
   DCS   SBA,(08,66),X'08C6',RTA,(08,70),X'08A2'
   DCS   SBA,(09,66),X'08C6',RTA,(09,70),X'08A2'
   DCS   SBA,(10,66),X'08C6',RTA,(10,70),X'08A2'
   DCS   SBA,(11,66),X'08C6',RTA,(11,70),X'08A2'
   DCS   SBA,(12,66),X'08C6',RTA,(12,70),X'08A2'
   DCS   SBA,(13,66),X'08C6',RTA,(13,70),X'08A2'
   DCS   SBA,(14,66),X'08C6',RTA,(14,70),X'08A2'
   DCS   SBA,(15,66),X'08C6',RTA,(15,70),X'08A2'
   DCS   SBA,(16,66),X'08C6',RTA,(16,70),X'08A2'
   DCS   SBA,(17,66),X'08C6',RTA,(17,70),X'08A2'
   DCS   SBA,(18,66),X'08C6',RTA,(18,70),X'08A2'
   DCS   SBA,(19,66),X'08C6',RTA,(19,70),X'08A2'
   DCS   SBA,(20,66),X'08C6',RTA,(20,70),X'08A2',SBA,(20,70),X'08D6'
   DCS   SBA,(21,66),X'08C6',RTA,(21,70),X'08A2',SBA,(21,70),X'08D6'
   DCS   SBA,(22,66),X'08C6',RTA,(22,70),X'08A2',SBA,(22,70),X'08D6'
   DCS   SBA,(23,66),X'08C6',RTA,(23,70),X'08A2',SBA,(23,70),X'08D6'
*
*    INSERT URINE
*
         DCS   SA,COLOUR,YELLOW
THETHNG  DC    X'11016B',X'08B3'
LOCPIS   DC    X'1101BB',X'08A1'
*
*    INSERT MAN
*
COVER    DC    X'11016B',X'00'
         DC    X'1101BB',X'00'
         DCS   SA,COLOUR,PINK        WRITE
LOC1     DC    X'11063D',X'08FD',X'00'
LOC2     DC    X'11068D',X'0895',X'0891',X'00'
LOC3     DC    X'1106DD'
         DCS   SA,COLOUR,GREEN
         DC    X'0895',X'0891',X'00'
         DCS   SA,COLOUR,PINK
LOC4     DC    X'11072D'
         DC    1XL4'08910891'
*
*    INSERT DIVER RAIL
*
   DCS   SA,COLOUR,WHITE,SF,UNPLO
   DCS   SBA,(07,70),X'08D6'
   DCS   SBA,(08,70),X'08D6'
   DCS   SBA,(09,70),X'08D6'
   DCS   SBA,(10,70),X'08D6'
   DCS   SBA,(11,70),X'08D6'
   DCS   SBA,(12,70),X'08D6'
   DCS   SBA,(13,70),X'08D6'
   DCS   SBA,(14,70),X'08D6'
   DCS   SBA,(15,70),X'08D6'
   DCS   SBA,(16,70),X'08D6'
   DCS   SBA,(17,70),X'08D6'
   DCS   SBA,(18,70),X'08D6'
   DCS   SBA,(19,70),X'08D6'
   DCS   SA,COLOUR,BLUE,SF,UNPLO
   DCS   SBA,(04,55),X'08C5'
   DC    X'08A208D708A208D708A2'
   DC    X'08D708A208D708A2'
   DCS   SBA,(04,70),X'08C5'
   DC    X'08D708A208D708A2'
   DCS   SBA,(04,74),X'08D5'
   DCS   SBA,(05,55),X'0885'
   DCS   SBA,(05,57),X'0885'
   DCS   SBA,(05,59),X'0885'
   DCS   SBA,(05,61),X'0885'
   DCS   SBA,(05,63),X'0885'
   DCS   SBA,(05,65),X'0885'
   DCS   SBA,(05,71),X'0885'
   DCS   SBA,(05,73),X'0885'
   DCS   SBA,(05,74),X'0885'
   DCS   SA,COLOUR,WHITE,SF,UNPLO
   DCS   SBA,(03,65),X'08C508D5',SBA,(03,70),X'08C508D5'
   DCS   SBA,(04,65),X'08D30885',SBA,(04,70),X'088508D3'
   DCS   SBA,(05,65),X'08850885',SBA,(05,70),X'08850885'
   DCS   SBA,(06,66),X'0885',SBA,(06,70),X'0885'
   DCS   SA,COLOUR,BLUE,SF,UNPLO
   DCS   SBA,(06,55),X'0885'
   DCS   SBA,(06,57),X'0885'
   DCS   SBA,(06,59),X'0885'
   DCS   SBA,(06,61),X'0885'
   DCS   SBA,(06,63),X'0885'
   DCS   SBA,(06,65),X'0885'
   DCS   SBA,(06,71),X'0885'
   DCS   SBA,(06,73),X'0885'
   DCS   SBA,(06,74),X'0885'
*
*    INSERT SWIMMING POOL ORIGINAL
*
   DCS   SA,COLOUR,TURQ,SF,UNPLO
   DCS   SBA,(21,2),RTA,(21,57),X'0895'
   DCS   SBA,(22,2),RTA,(22,57),X'0895'
   DCS   SBA,(23,2),RTA,(23,57),X'0895'
   DCS   SA,COLOUR,BLUE,SF,UNPLO
   DCS   SBA,(20,2),RTA,(20,57),X'08A2',SBA,(20,57),X'08D5'
   DCS   SBA,(21,57),X'0885'
   DCS   SBA,(22,57),X'0885'
   DCS   SBA,(23,57),X'0885'
*
*    INSERT SWIMMING POOL YELLOWED
*
POOLCOL  DCS   SA,COLOUR,TURQ,SF,UNPLO
PL1      DC    X'11065C',X'3C065D',X'0895'
PL2      DC    X'1106AC',X'3C06AD',X'0895'
PL3      DC    X'1106FC',X'3C06FD',X'0895'
*
*  INSERT CURSOR
*
         DCS   SBA,(02,02),IC
SCRN1LEN EQU   *-SCRN1     ########  END OF DEFAULT SCREEN  ########
*
*  INSERT ???????????????
*
*
*  ADDITIONAL DATA
*
CLRSCRN DCS   X'F1C5',SBA,(1,1),RTA,(24,80),X'00'
CLREND  EQU   *-CLRSCRN
*
* ####################################################################
*
         END   DIVER
//LKED.SYSLMOD DD DSN=SYS2.CMDLIB,DISP=SHR
//LKED.SYSIN DD *
 ENTRY   DIVER
 NAME    DIVER(R)
//