using NLua;
using System;
using System.Collections.Generic;
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

        }

        public void stop()
        {

        }
    }
}
