using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Input;
using NLua;
using NLua.Exceptions;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection.Metadata.Ecma335;
using System.Text;

namespace Love2D
{
    public class Keyboard
    {
        private Lua lua;
        private Game game;
        private KeyboardState ks;
        private KeyboardState oks;
        private GamePadState ogs;
        private Dictionary<Buttons, string> padbuttons;

        public Keyboard(Lua l, Game g, Dictionary<Buttons, string> pad)
        {
            lua = l;
            game = g;
            padbuttons = pad;

            lua.NewTable("love.keyboard");
            lua.RegisterFunction("love.keyboard.scan", this, typeof(Keyboard).GetMethod("scan"));
            lua.RegisterFunction("love.keyboard.isDown", this, typeof(Keyboard).GetMethod("isDown"));
        }

        public void scan()
        {
            ks = Microsoft.Xna.Framework.Input.Keyboard.GetState();
            Keys[] newkeys = ks.GetPressedKeys();
            Keys[] relkeys = GetReleasedKeys();

            var gs = GetJoyStickState();
            var using_joystick = false;

            foreach (var button in padbuttons)
            {
                var but = padbuttons.FirstOrDefault(x => x.Value == button.Value).Key;
                if (gs.IsButtonDown(but) && !ogs.IsButtonDown(but))
                {
                    lua.GetFunction("love.keypressed").Call(button.Value.ToLower());
                    using_joystick = true;
                }
            }

            if (!using_joystick)
            {
                foreach (Keys key in newkeys)
                {
                    if (ks.IsKeyDown(key) && !oks.IsKeyDown(key))
                    {
                        lua.GetFunction("love.keypressed").Call(key.ToString().ToLower());
                    }
                }
            }

            foreach (var button in padbuttons)
            {
                var but = padbuttons.FirstOrDefault(x => x.Value == button.Value).Key;
                if (gs.IsButtonUp(but) && !ogs.IsButtonUp(but))
                {
                    lua.GetFunction("love.keyreleased").Call(button.Value.ToLower());
                    using_joystick = true;
                }
            }

            if (!using_joystick)
            {
                foreach (Keys key in relkeys)
                {
                    if (ks.IsKeyUp(key) && !oks.IsKeyUp(key))
                    {
                        lua.GetFunction("love.keyreleased").Call(key.ToString().ToLower());
                    }
                }
            }

            oks = ks;
            ogs = gs;
        }

        public bool isDown(params string[] args)
        {
            ks = Microsoft.Xna.Framework.Input.Keyboard.GetState();
            Keys[] newkeys = ks.GetPressedKeys();
            string keystring = args[0];

            var gs = GetJoyStickState();

            foreach (var button in padbuttons)
            {
                var but = padbuttons.FirstOrDefault(x => x.Value == button.Value).Key;
                if (gs.IsButtonDown(but) && keystring == button.Value.ToLower())
                {
                    return true;
                }
            }

            foreach (Keys key in newkeys)
            {
                if ((ks.IsKeyDown(key) && keystring == key.ToString().ToLower()))
                {
                    return true;
                }
            }

            return false;
        }

        GamePadState GetJoyStickState()
        {
            GamePadState gs = new GamePadState();
            for (int i = 0; i < 4; i++)
            {
                gs = GamePad.GetState(i);
                if (gs.IsConnected)
                {
                    return gs;
                }
            }
            return gs;
        }

        Keys[] GetReleasedKeys()
        {
            return Enum.GetValues(typeof(Keys))
                       .Cast<Keys>()
                       .Where(b => ks.IsKeyUp(b))
                       .ToArray();
        }

        void lua_print(object text)
        {
            Console.WriteLine(text.ToString());
        }
    }
}
