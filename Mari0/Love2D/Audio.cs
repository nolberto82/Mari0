using Microsoft.Xna.Framework.Audio;
using NLua;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace Love2D
{
    public class Audio
    {
        private Lua lua;

        public Audio(Lua l)
        {
            lua = l;

            lua.NewTable("love.audio");
            lua.RegisterFunction("love.audio.stop", this, typeof(Audio).GetMethod("stop"));
            lua.RegisterFunction("love.audio.newSource", this, typeof(Audio).GetMethod("newSource"));
        }

        public void stop(params object[] args)
        {
            if (args.Length == 0)
            {
                return;
            }

            Sound sound = (Sound)args[0];
            if (sound != null)
            {
                sound.sound.Stop();
            }
        }

        public Sound newSource(params string[] args)
        {
            var path = args[0];

            List<Sound> obj_sound = new List<Sound>();
            obj_sound.Add(new Sound(path));

            return obj_sound[0];
        }
    }
}
