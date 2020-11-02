using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;

namespace Credentials
{
    public static class Advapi32dll
    {
        private const string Advapi32Dll = "advapi32.dll";

        public static (bool success, string username, string password) GetCredentials(string target, CRED_TYPE credType = CRED_TYPE.GENERIC)
        {
            var username = string.Empty;
            var password = string.Empty;
            var credentialPtr = IntPtr.Zero;

            try
            {
                bool success = Advapi32dll.CredRead(target, Advapi32dll.CRED_TYPE.GENERIC, 0, out credentialPtr);
                if (success)
                {
                    var credential = (Advapi32dll.CREDENTIAL)Marshal.PtrToStructure(credentialPtr, typeof(Advapi32dll.CREDENTIAL));
                    username = credential.UserName;

                    if (credential.CredentialBlobSize > 2)
                    {
                        password = Marshal.PtrToStringUni(credential.CredentialBlob, (int)credential.CredentialBlobSize / 2);
                    }
                }

                return (success, username, password);
            }
            finally
            {
                if (credentialPtr != IntPtr.Zero)
                {
                    CredFree(credentialPtr);
                }
            }
        }

        public static (bool success, int errorCode) StoreCredentials(string target, string username, string password, CRED_TYPE type = CRED_TYPE.GENERIC)
        {
            byte[] byteArray = Encoding.Unicode.GetBytes(password);

            if (byteArray.Length > 512)
            {
                throw new ArgumentOutOfRangeException("The secret message has exceeded 512 bytes.");
            }

            CREDENTIAL credentailPtr = new CREDENTIAL
            {
                AttributeCount = 0,
                CredAttribute = IntPtr.Zero,
                Comment = null,
                TargetAlias = null,
                Type = type,
                Persist = (UInt32)CRED_PERSIST.ENTERPRISE,
                CredentialBlobSize = (UInt32)Encoding.Unicode.GetBytes(password).Length,
                TargetName = target,
                CredentialBlob = Marshal.StringToCoTaskMemUni(password),
                UserName = username
            };

            bool written = CredWrite(ref credentailPtr, 0);
            int lastError = Marshal.GetLastWin32Error();

            if (written)
            {
                return (true, 0);
            }

            return (false, lastError);
        }

        public static IEnumerable<string> ListCredentialTargets()
        {
            var credentialsListPtr = IntPtr.Zero;

            try
            {
                var status = CredEnumerate(null, 0x1, out int count, out credentialsListPtr);

                if (status)
                {
                    for (int n = 0; n < count; n++)
                    {
                        IntPtr credentialPtr = Marshal.ReadIntPtr(credentialsListPtr, n * Marshal.SizeOf(typeof(IntPtr)));
                        var credential = (CREDENTIAL)Marshal.PtrToStructure(credentialPtr, typeof(CREDENTIAL));

                        yield return credential.TargetName;
                    }
                }
                else
                {
                    int lastError = Marshal.GetLastWin32Error();
                    throw new Exception($"Error code: {lastError}");
                }
            }
            finally
            {
                if (credentialsListPtr != IntPtr.Zero)
                {
                    CredFree(credentialsListPtr);
                }
            }
        }

        public static bool DeleteCredentials(string target, CRED_TYPE type = CRED_TYPE.GENERIC)
        {
            return CredDelete(target, type, 0);
        }

        [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)]
        public struct CREDENTIAL
        {
            public UInt32 Flags;
            public CRED_TYPE Type;
            public string TargetName;
            public string Comment;
            public FILETIME LastWritten;
            public UInt32 CredentialBlobSize;
            public IntPtr CredentialBlob;
            public UInt32 Persist;
            public UInt32 AttributeCount;
            public IntPtr CredAttribute;
            public string TargetAlias;
            public string UserName;

        }

        [StructLayout(LayoutKind.Sequential)]
        public struct FILETIME {
            public uint DateTimeLow;
            public uint DateTimeHigh;
        }

        public enum CRED_TYPE : uint
        {
            GENERIC = 1,
            DOMAIN_PASSWORD = 2,
            DOMAIN_CERTIFICATE = 3,
            DOMAIN_VISIBLE_PASSWORD = 4,
            GENERIC_CERTIFICATE = 5,
            DOMAIN_EXTENDED = 6,
            MAXIMUM = 7,                    // Maximum supported cred type
            MAXIMUM_EX = (MAXIMUM + 1000),  // Allow new applications to run on old OSes
        }

        public enum CRED_PERSIST : uint
        {
            SESSION = 1,
            LOCAL_MACHINE = 2,
            ENTERPRISE = 3,
        }

        [DllImport(Advapi32Dll, EntryPoint="CredReadW", CharSet = CharSet.Unicode, SetLastError = true)]
        private static extern bool CredRead(string target, CRED_TYPE type, int reservedFlag, out IntPtr credentialPtr);

        [DllImport(Advapi32Dll, EntryPoint = "CredWriteW", CharSet = CharSet.Unicode, SetLastError = true)]
        private static extern bool CredWrite([In] ref CREDENTIAL userCredential, [In] UInt32 flags);

        [DllImport(Advapi32Dll, EntryPoint = "CredFree", CharSet = CharSet.Unicode, SetLastError = true)]
        private static extern void CredFree(IntPtr credentialPtr);

        [DllImport(Advapi32Dll, EntryPoint = "CredEnumerateW", CharSet = CharSet.Unicode, SetLastError = true)]
        internal static extern bool CredEnumerate(string filter, int flag, out int count, out IntPtr credentials);

        [DllImport(Advapi32Dll, EntryPoint = "CredDeleteW", CharSet = CharSet.Unicode, SetLastError = true)]
        internal static extern bool CredDelete(string target, CRED_TYPE type, int flag);
    }
}