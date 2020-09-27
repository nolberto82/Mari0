using NLua;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace Love2D
{
    public class Filesystem
    {
        private Lua lua;

        public Filesystem(Lua l)
        {
            lua = l;

            lua.NewTable("love.filesystem");
            lua.RegisterFunction("love.filesystem.read", this, typeof(Filesystem).GetMethod("read"));
            lua.RegisterFunction("love.filesystem.write", this, typeof(Filesystem).GetMethod("write"));
            lua.RegisterFunction("love.filesystem.getInfo", this, typeof(Filesystem).GetMethod("getInfo"));
        }

        public string read(params string[] args)
        {
            string path = args[0];

            if (!File.Exists(path))
                return null;

            return File.ReadAllText(path);
        }

        public void write(params string[] args)
        {
            var path = args[0];
            var s = args[1];

            File.WriteAllText(path, s);
        }

        public bool getInfo(params string[] args)
        {
            string path = args[0];

            if (File.Exists(path))
            {
                return true;
            }
            else
            {
                return false;
            }
        }
    }
}
