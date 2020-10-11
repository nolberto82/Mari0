using Love2D;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework.Input;
using NLua;
using NLua.Exceptions;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using System.Windows.Forms.Design;
using static KeraLua.Lua;

namespace Mari0
{
    public partial class Game1 : Game
    {
        private Dictionary<Buttons, string> padbuttons;
        private string error;
        private Graphics gfx;
        private Window win;
        private Filesystem file;
        private Audio audio;
        private Thread thread;
        private Love2D.Keyboard key;
        private bool directoryset;
        private string projectpath;
        private string luaprojectpath;
        private KeyboardState ks;
        private KeyboardState oks;

        void LuaLoad()
        {
            padbuttons = new Dictionary<Buttons, string>
            {
                { Buttons.DPadRight, "right"},
                { Buttons.DPadLeft, "left"},
                { Buttons.DPadDown, "down"},
                { Buttons.DPadUp, "up"},
                { Buttons.A, "x"},
                { Buttons.B, "z"},
                { Buttons.Start, "enter"},
                { Buttons.RightShoulder, "a"}
            };

            lua = new Lua();

            error = string.Empty;

            if (!directoryset)
            {
                projectpath = Path.GetFullPath(@"..\..\..\..");
                Directory.SetCurrentDirectory(Environment.CurrentDirectory + "\\Content\\lua");
                luaprojectpath = Environment.CurrentDirectory;
                luaprojectpath = luaprojectpath.Replace('\\', '/');
                directoryset = true;
            }

            lua.NewTable("love");
            ((LuaTable)lua["love"])["load"] = null;
            ((LuaTable)lua["love"])["draw"] = null;
            ((LuaTable)lua["love"])["update"] = null;
            ((LuaTable)lua["love"])["quit"] = null;
            ((LuaTable)lua["love"])["keypressed"] = null;

            //Graphics
            gfx = new Graphics(lua, this);
            win = new Window(lua, this, graphics, gfx);
            file = new Filesystem(lua);
            audio = new Audio(lua);
            key = new Love2D.Keyboard(lua, this, padbuttons);
            thread = new Thread(lua);

            //lua.RegisterFunction("lua_remove", this, typeof(Game1).GetMethod("lua_remove_alt"));

#if DEBUG
            CopyFolders();
#endif

            lua.DoString(@"package.path = package.path ..';" + luaprojectpath + "/?.lua'");
            //lua.DoString(@"package.cpath = package.cpath ..';" + luaprojectpath + "/debuggee/socket/?.dll'");
            lua.DoFile("main.lua");

            try
            {
                lua.GetFunction("love.load").Call();
            }
            catch (LuaScriptException e)
            {
                error = e.Message + Environment.NewLine;
                error += e.Source;
                lua_print(error);
            }
        }

        void LuaUpdate(float dt)
        {
            ks = Microsoft.Xna.Framework.Input.Keyboard.GetState();

            bool f5 = ks.IsKeyDown(Keys.F5) && oks.IsKeyUp(Keys.F5);

            if (f5)
            {
                LuaLoad();
            }

            if (error == string.Empty)
            {
                try
                {
                    lua.GetFunction("love.update").Call(dt);
                    key.scan();
                }
                catch (LuaScriptException e)
                {
                    error = e.Message + Environment.NewLine;
                    error += e.Source;
                    lua_print(error);
                }
            }

            //lua_print(f5);
            //lua_print(lua["xscroll"]);
            oks = ks;
        }

        void LuaDraw()
        {
            GraphicsDevice.Clear(gfx.getBackgroundColor());

            //sb.Begin(SpriteSortMode.Immediate, BlendState.AlphaBlend, gfx.getDefaultFilter());

            try
            {
                lua.GetFunction("love.draw").Call();
            }
            catch (LuaScriptException e)
            {
                error = e.Message + Environment.NewLine;
                error += e.Source;
                lua_print(error);
            }

            //sb.End();
        }

        void CopyFolders()
        {
            var srcpath = projectpath + "\\Content\\lua";
            var dstpath = Directory.GetCurrentDirectory();
            var srcinfo = new DirectoryInfo(srcpath);
            var dstinfo = new DirectoryInfo(dstpath);
            Directory.CreateDirectory(dstinfo.FullName);

            // Use ProcessStartInfo class
            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.CreateNoWindow = false;
            startInfo.UseShellExecute = false;

            //Give the name as Xcopy
            startInfo.FileName = "xcopy";

            //make the window Hidden
            startInfo.WindowStyle = ProcessWindowStyle.Hidden;

            //Send the Source and destination as Arguments to the process
            startInfo.Arguments = "\"" + srcinfo.FullName + "\"" + " " + "\"" + dstinfo.FullName + "\"" + @" /e /y /I /s /d";

            try
            {
                using (Process exeProcess = Process.Start(startInfo))
                {
                    exeProcess.WaitForExit();
                }
            }
            catch (Exception exp)
            {
                throw exp;
            }
        }

        public static void lua_print(object text)
        {
            Console.WriteLine(text.ToString());
        }

        public static void lua_remove_alt()
        {
            Console.WriteLine("success");
        }
    }
}
