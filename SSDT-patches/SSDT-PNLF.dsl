/*
 * Add PNLF.
 */
DefinitionBlock("", "SSDT", 2, "ACDT", "PNLF", 0x00000000)
{
    Scope(\_SB)
    {
        Device(PNLF)
        {
            Name(_ADR, Zero)  // _ADR: Address
            Name(_HID, EisaId ("APP0002"))  // _HID: Hardware ID
            Name(_CID, "backlight")  // _CID: Compatible ID
            //Haswell/Broadwell
            Name(_UID, 15)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (_OSI ("Darwin"))
                {
                    Return (0x0B)
                }
                Else
                {
                    Return (Zero)
                }
            }
        }
    }
}
