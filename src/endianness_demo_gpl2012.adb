--pragma Ada_2005;
with System.Storage_Elements; use System.Storage_Elements;
with Ada.Text_IO;             use Ada.Text_IO;

procedure Endianness_Demo_GPL2012 is
   type RegByte_Type is mod 2**8;
   for RegByte_Type'Size use 8;

   type RegWord_Type is mod 2**16;
   for RegWord_Type'Size use 16;

   type RegPair_Option is (PairReg, SingleReg);

   type Register_Width is (Half, Full);
   type CPU_Registers (Width : Register_Width := Half) is record
      SP : RegWord_Type;
      case Width is
         when Half =>
            --  F : CPU_Flags;
            A, C, B, E, D, L, H : RegByte_Type;
         when Full =>
            AF, BC, DE, HL : RegWord_Type;
      end case;
   end record;

   type JJ_Registers (Option : RegPair_Option := PairReg) is record
      case Option is
         when PairReg =>
            AF, BC, DE, HL : RegWord_Type;
         when SingleReg =>
            A, F, B, C, D, E, H, L : RegByte_Type;
      end case;
   end record;
   for JJ_Registers use record
      AF at 0 range  0 .. 15;
      BC at 2 range 16 .. 31;
      DE at 4 range 32 .. 47;
      HL at 6 range 48 .. 63;

      A at 0 range  0 ..  7;
      F at 1 range  8 .. 15;
      B at 2 range 16 .. 23;
      C at 3 range 24 .. 31;
      D at 4 range 32 .. 39;
      E at 5 range 40 .. 47;
      H at 6 range 48 .. 55;
      L at 7 range 56 .. 63;
   end record;

   type RegPair_Type (Width : RegPair_Option := PairReg) is record
      case Width is
         when PairReg =>
            Value : RegWord_Type;
         when SingleReg =>
            HighValue : RegByte_Type;
            LowValue  : RegByte_Type;
      end case;
   end record;
   pragma Unchecked_Union (RegPair_Type);

   for RegPair_Type use record
      Value     at 0 range 0 .. 15;
      HighValue at 0 range 0 ..  7;
      LowValue  at 0 range 8 .. 15;
   end record;
   for RegPair_Type'Bit_Order use System.High_Order_First;
   for RegPair_Type'Scalar_Storage_Order use System.High_Order_First;

   -------------------------
   -- Common declarations --
   -------------------------

   subtype Yr_Type is Natural range 0 .. 127;
   subtype Mo_Type is Natural range 1 .. 12;
   subtype Da_Type is Natural range 1 .. 31;

   type Date is record
      Years_Since_1980 : Yr_Type;
      Month            : Mo_Type;
      Day_Of_Month     : Da_Type;
   end record;

   for Date use record
      Years_Since_1980 at 0 range  0 ..  6;
      Month            at 0 range  7 .. 10;
      Day_Of_Month     at 0 range 11 .. 15;
   end record;

   ------------------------------------------------------------
   -- Derived types with different representation attributes --
   ------------------------------------------------------------

   --  Bit order only

   type Date_LE_Bits is new Date;
   for Date_LE_Bits'Bit_Order use System.Low_Order_First;

   type Date_BE_Bits is new Date;
   for Date_BE_Bits'Bit_Order use System.High_Order_First;

   --  Bit order and scalar storage order (note: if the latter is specified, it
   --  must be consistent with the former).

   type Date_LE is new Date;
   for Date_LE'Bit_Order use System.Low_Order_First;
   for Date_LE'Scalar_Storage_Order use System.Low_Order_First;

   type Date_BE is new Date;
   for Date_BE'Bit_Order use System.High_Order_First;
   for Date_BE'Scalar_Storage_Order use System.High_Order_First;

   ----------------------------
   -- Show bits at address A --
   ----------------------------

   procedure Show (A : System.Address) is
      Arr : Storage_Array (1 .. 2);
      for Arr'Address use A;
      pragma Import (Ada, Arr);
   begin
      for J in Arr'Range loop
         Put (Arr (J)'Img);
      end loop;
      New_Line;
   end Show;

   D_N : Date := (32, 12, 12);
   --  Native storage (no attribute specified)

   D_LE_Bits : Date_LE_Bits := (32, 12, 12);
   D_BE_Bits : Date_BE_Bits := (32, 12, 12);

   D_LE : Date_LE;
   D_BE : Date_BE;

   RegPairHL : RegPair_Type;
   RegPairBC : RegPair_Type;
   jjRegs    : JJ_Registers;
begin
   RegPairHL.Value := 16#F0#;
   RegPairBC := (Width => SingleReg, HighValue => 16#AB#, LowValue => 16#CD#);

   --  jjRegs.DE := 16#a5#;
   --  jjRegs := (Option => SingleReg, D => 16#a#);
   --

   --  RegPairBC.HighValue := 16#A#; RegPairBC.LowValue := 16#5#;
   --  RegPairBC.Value := 1;
   --
   Put_Line ("BC : " & RegPairBC.Value'Img);
   Put_Line ("HL : " & RegPairHL.Value'Img);

   Put_Line ("Default bit order: " & System.Default_Bit_Order'Img);

   Put ("N      :");
   Show (D_N'Address);

   Put ("LE_Bits:");
   Show (D_LE_Bits'Address);
   Put ("BE_Bits:");
   Show (D_BE_Bits'Address);

   --  Note: in GNAT GPL 2012, intialization of a non-default-endianness record
   --  from an aggregate of whole-record assignment is not done correctly, so
   --  perform per-component assignments here. This has been fixed in GNAT Pro
   --  7.1 and the fix will also be in GNAT GPL 2013.

   --  D_LE.Years_Since_1980 := 32; D_LE.Month := 12; D_LE.Day_Of_Month := 12;
   --
   --  D_BE.Years_Since_1980 := 32; D_BE.Month := 12; D_BE.Day_Of_Month := 12;

   Put ("LE:     ");
   Show (D_LE'Address);
   Put ("BE:     ");
   Show (D_BE'Address);
end Endianness_Demo_GPL2012;
