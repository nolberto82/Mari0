using Love2D;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Input;
using NLua;
using NLua.Exceptions;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

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
        private Love2D.Keyboard key;
        private bool directoryset;

        void LuaLoad()
        {
            padbuttons = new Dictionary<Buttons,string>
            {
                { Buttons.DPadRight, "right"},
                { Buttons.DPadLeft, "left"},
                { Buttons.DPadDown, "down"},
                { Buttons.DPadUp, "up"},
                { Buttons.A, "x"},
                { Buttons.B, "z"},
                { Buttons.Start, "enter"}
            };

            error = string.Empty;
            if (!directoryset)
            {
                Directory.SetCurrentDirectory(Environment.CurrentDirectory + "\\Content\\lua");
                directoryset = true;
            }

            lua = new Lua();

            lua.NewTable("love");
            ((LuaTable)lua["love"])["load"] = null;
            ((LuaTable)lua["love"])["draw"] = null;
            ((LuaTable)lua["love"])["update"] = null;
            ((LuaTable)lua["love"])["quit"] = null;
            ((LuaTable)lua["love"])["keypressed"] = null;

            //lua.RegisterFunction("print", null, typeof(Game1).GetMethod("lua_print"));

            //Graphics
            gfx = new Graphics(lua, this);
            win = new Window(lua, this, graphics);
            file = new Filesystem(lua);
            audio = new Audio(lua);
            key = new Love2D.Keyboard(lua, this, padbuttons);

            lua.DoString("package.path = package.path .. ';/Content/lua/?.lua'");
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

            //lua_print(lua["xscroll"]);
        }

        void LuaDraw()
        {
            GraphicsDevice.Clear(gfx.getBackgroundColor());
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
        }

        public static void lua_print(object text)
        {
            Console.WriteLine(text.ToString());
        }
    }
}
