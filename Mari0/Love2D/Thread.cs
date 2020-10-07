using NLua;
using System;
using System.Collections.Generic;
using System.Text;

namespace Love2D
{
    public class Thread
    {
        private Lua lua;

        public Thread(Lua l)
        {
            lua = l;

            lua.NewTable("love.thread");
            lua.RegisterFunction("love.thread.newThread", this, typeof(Thread).GetMethod("newThread"));
            //lua.RegisterFunction("love.audio.newSource", this, typeof(Audio).GetMethod("newSource"));
        }

        public void newThread(params string[] args)
        {
            var path = args[0];


        }
    }
}
