/*
 * This file is a tiny SSDT for ASRock-H81M.
 * It's a alternate for all SSDT patches.
 * Credit: @JFZ (https://github.com/lichongjia)
 */
DefinitionBlock ("", "SSDT", 1, "APPLE", "tinySSDT", 0x00000006)
{
    External (_SB_.PCI0, DeviceObj)
    External (_SB_.PCI0.LPCB, DeviceObj)
    External(XPRW, MethodObj)
    External (_PR_.CPU0, ProcessorObj)
    External (_SB_.PCI0.SBUS.BUS0, DeviceObj)

If (_OSI ("Darwin"))
{
    Scope (\_SB)
    {
        Scope (PCI0)
        {
            Scope (LPCB)
            {
                /* Add Device ALS0.
                 * Starting with macOS 10.15 Ambient Light Sensor presence is required for backlight functioning.
                 */
                Device (ALS0)
                {
                    Name (_HID, "ACPI0008" /* Ambient Light Sensor Device */)  // _HID: Hardware ID
                    Name (_CID, "smc-als")  // _CID: Compatible ID
                    Name (_ALI, 0x012C)  // _ALI: Ambient Light Illuminance
                    Name (_ALR, Package (0x01)  // _ALR: Ambient Light Response
                    {
                        Package (0x02)
                        {
                            0x64, 
                            0x012C
                        }
                    })
                }

                /* Add Device EC.
                 * AppleUsbPower compatibility table for legacy hardware.
                 */              
                Device (EC)
                {
                    Name (_HID, "ACID0001")  // _HID: Hardware ID
                }
            }
            
            /*
             * Add Device MCHC.
             * SMBus compatibility table.
             */
            Device (MCHC)
            {
                Name (_ADR, Zero)  // _ADR: Address
            }

            Device (SBUS.BUS0)
            {
                Name (_CID, "smbus")  // _CID: Compatible ID
                Name (_ADR, Zero)  // _ADR: Address
                Device (DVL0)
                {
                    Name (_ADR, 0x57)  // _ADR: Address
                    Name (_CID, "diagsvault")  // _CID: Compatible ID
                    Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                    {
                        If (!Arg2)
                        {
                            Return (Buffer (One)
                            {
                                 0x57                                             // W
                            })
                        }

                        Return (Package (0x02)
                        {
                            "address", 
                            0x57
                        })
                    }
                }
            }
        }//PCI0

        /* Add Device MEM2 */
        Device(PNLF)
        {
            Name(_HID, EisaId ("APP0002"))  // _HID: Hardware ID
            Name(_CID, "backlight")  // _CID: Compatible ID
            //Haswell/Broadwell
            Name(_UID, 15)  // _UID: Unique ID
        }    
    
        /* Add Device SLPB */
        Device (SLPB)
        {
            Name (_HID, EisaId ("PNP0C0E") /* Sleep Button Device */)  // _HID: Hardware ID
        }
    }//\_SB

    /* Disable EHC1 and EHC2 with SSDT-EHCx_OFF */
    Scope (\)
    {
        OperationRegion (RCRG, SystemMemory, 0xFED1F418, One)
        Field (RCRG, DWordAcc, Lock, Preserve)
        {
                ,   13, 
            EH2D,   1, 
                ,   1, 
            EH1D,   1
        }

        Method (_INI, 0, NotSerialized)  // _INI: Initialize
        {
            EH1D = One  // Disable EHC1
            EH2D = One  // Disable EHC2
        }
    }

    /*
     * In config ACPI, GPRW to XPRW
     * Find:     47505257 02
     * Replace:  58505257 02
     */
    Method (GPRW, 2, NotSerialized)
    {
        While (One)
        {
            If ((0x6D == Arg0))
            {
                Return (Package ()
                {
                    0x6D, 
                    Zero
                })
            }

            If ((0x0D == Arg0))
            {
                Return (Package ()
                {
                    0x0D, 
                    Zero
                })
            }
            
            Break
        }
        Return (XPRW (Arg0, Arg1))
    }

    /* Add Device MEM2 */
    Device (MEM2)
    {
        Name (_HID, EisaId ("PNP0C01"))
        Name (_UID, 0x02)
        Name (CRS, ResourceTemplate ()
        {
            Memory32Fixed (ReadWrite,
                0x20000000,         // Address Base
                0x00200000,         // Address Length
                )
            Memory32Fixed (ReadWrite,
                0x40000000,         // Address Base
                0x00200000,         // Address Length
                )
        })
        Method (_CRS, 0, NotSerialized)
        {
            Return (CRS)
        }
    }

    /* XCPM power management compatibility table */
    Scope (\_PR.CPU0)
    {
        Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
        {
            Local0 = Package (0x02)
                {
                    "plugin-type", 
                    One
                }
            DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
            Return (Local0)
        }
    }

    /* Add DTGP Method */
    Method (DTGP, 5, NotSerialized)
    {
        If ((Arg0 == ToUUID ("a0b5b7c6-1318-441c-b0c9-fe695eaf949b")))
        {
            If ((Arg1 == One))
            {
                If ((Arg2 == Zero))
                {
                    Arg4 = Buffer (One)
                        {
                             0x03                                             // .
                        }
                    Return (One)
                }

                If ((Arg2 == One))
                {
                    Return (One)
                }
            }
        }

        Arg4 = Buffer (One)
            {
                 0x00                                             // .
            }
        Return (Zero)
    }
}//IF
}