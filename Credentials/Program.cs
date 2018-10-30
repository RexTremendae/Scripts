using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Linq;

using static System.Console;

namespace Credentials
{
    public class Program
    {
        public static void Main(string[] args)
        {
            new Program().Run(args);
        }

        public void Run(string[] args)
        {
            WriteLine();

            var cmd = GetCommand(args);

            if (cmd == Command.Unknown)
            {
                PrintCommandUsage();
                return;
            }

            args = args.Skip(1).ToArray();

            switch (cmd)
            {
                case Command.Get:
                    GetCredentials(args);
                    break;

                case Command.Add:
                    AddCredentials(args);
                    break;

                case Command.List:
                    ListCredentials(args);
                    break;

                case Command.Delete:
                    DeleteCredentials(args);
                    break;
            }

            WriteLine();
        }

        private void ListCredentials(string[] args)
        {
            foreach (var target in Advapi32dll.ListCredentialTargets())
            {
                var splitIdx = target.IndexOf('=');

                if (splitIdx < 0)
                {
                    Console.WriteLine(target);
                }
                else
                {
                    Write(target.Substring(0, splitIdx+1));
                    ColorWriteLine(target.Substring(splitIdx+1, target.Length-splitIdx-1), ConsoleColor.Yellow);
                }
            }
        }

        private void AddCredentials(string[] args)
        {
            if (args.Length < 3)
            {
                Write("Please provide ");
                ColorWrite("target", ConsoleColor.Yellow);
                Write(", ");
                ColorWrite("username", ConsoleColor.Yellow);
                Write(" and ");
                ColorWrite("password", ConsoleColor.Yellow);
                WriteLine(".");

                return;
            }

            var (success, errorCode) = Advapi32dll.StoreCredentials(args[0], args[1], args[2]);

            if (success)
            {
                ColorWriteLine("Credentials written successfully!", ConsoleColor.Green);
            }
            else
            {
                ColorWrite("ERROR: ", ConsoleColor.Red);
                WriteLine("Failed to write credentials!");
                Write("Error code: ");
                ColorWrite(errorCode.ToString(), ConsoleColor.Red);
            }
        }

        private void DeleteCredentials(string[] args)
        {
            if (args.Length < 1)
            {
                Write("Please provide ");
                ColorWrite("target", ConsoleColor.Yellow);
                WriteLine(".");
                return;
            }

            var success = Advapi32dll.DeleteCredentials(args[0]);

            if (!success)
            {
                ColorWriteLine("Could not delete credential.", ConsoleColor.Red);
                return;
            }

            ColorWrite("Success! ", ConsoleColor.Green);
            WriteLine("Credential deleted.");
        }

        private void GetCredentials(string[] args)
        {
            if (args.Length < 1)
            {
                Write("Please provide ");
                ColorWrite("target", ConsoleColor.Yellow);
                WriteLine(".");
                return;
            }

            var (success, username, password) = Advapi32dll.GetCredentials(args[0]);

            if (!success)
            {
                ColorWriteLine("Could not find credential.", ConsoleColor.Red);
                return;
            }

            Write("Username: ");
            ColorWriteLine(username, ConsoleColor.Green);

            Write("Password: ");
            ColorWriteLine(password, ConsoleColor.Green);
        }

        private static void ColorWrite(string text, ConsoleColor color)
        {
            var oldColor = ForegroundColor;

            try
            {
                ForegroundColor = color;
                Write(text);
            }
            finally
            {
                ForegroundColor = oldColor;               
            }
        }

        private static void ColorWriteLine(string text, ConsoleColor color)
        {
            var oldColor = ForegroundColor;

            try
            {
                ForegroundColor = color;
                WriteLine(text);
            }
            finally
            {
                ForegroundColor = oldColor;
            }
        }

        private Command GetCommand(string[] args)
        {
            if (args == null || args.Length == 0)
            {
                return Command.Unknown;
            }

            if (Enum.TryParse(args[0], true, out Command cmd))
            {
                return cmd;
            }

            return Command.Unknown;
        }

        private static void PrintCommandUsage()
        {
            Write("Please provide command: ");

            var availableCommandsArray = Enum.GetValues(typeof(Command));
            var availableCommands = new List<Command>();

            foreach (Command arrayCmd in availableCommandsArray)
            {
                if (arrayCmd != Command.Unknown)
                {
                    availableCommands.Add(arrayCmd);
                }
            }

            bool first = true;
            foreach (var cmd in availableCommands.Take(availableCommands.Count - 1))
            {
                if (!first) Write(", ");
                ColorWrite(cmd.ToString(), ConsoleColor.Yellow);
                first = false;
            }

            Write(" or ");
            ColorWrite(availableCommands.Last().ToString(), ConsoleColor.Yellow);
            WriteLine();
            WriteLine();
        }

        private enum Command
        {
            Unknown = 0,
            List,
            Get,
            Add,
            Delete
        }
    }
}