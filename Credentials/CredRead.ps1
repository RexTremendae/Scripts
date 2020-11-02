#region Pinvoke
#region Inline C#

[String] $Cred = @"
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;

namespace Credentials
{
    public class Credential
    {
        public bool Success { get; set; }
        public string Username { get; set; }
        public string Password { get; set; }
    }

    public static class Advapi32dll
    {
        private const string Advapi32Dll = "advapi32.dll";

        public static Credential GetCredentials(string target, CRED_TYPE credType = CRED_TYPE.GENERIC)
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

                return new Credential { Success = success, Username = username, Password = password };
            }
            catch
            {
                return new Credential { Success = false, Username = string.Empty, Password = string.Empty };
            }
            finally
            {
                if (credentialPtr != IntPtr.Zero)
                {
                    CredFree(credentialPtr);
                }
            }
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
        public struct FILETIME
        {
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

        [DllImport(Advapi32Dll, EntryPoint="CredReadW", CharSet = CharSet.Unicode, SetLastError = true)]
        private static extern bool CredRead(string target, CRED_TYPE type, int reservedFlag, out IntPtr credentialPtr);

        [DllImport(Advapi32Dll, EntryPoint = "CredFree", CharSet = CharSet.Unicode, SetLastError = true)]
        private static extern void CredFree(IntPtr credentialPtr);
    }
}
"@
#endregion

Add-Type $Cred
$devOpsCred = [Credentials.Advapi32dll]::GetCredentials("Target")
if ($devOpsCred.Success)
{
    Write-Host 'Success' -ForegroundColor Green
    Write-Host $devOpsCred.Username
    Write-Host $devOpsCred.Password
}
else
{
    Write-Host 'Failure' -ForegroundColor Red
}
