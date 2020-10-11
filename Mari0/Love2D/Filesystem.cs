using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using NLua;

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
            lua.RegisterFunction("love.filesystem.getDirectoryItems", this, typeof(Filesystem).GetMethod("getDirectoryItems"));
            lua.RegisterFunction("love.filesystem.createDirectory", this, typeof(Filesystem).GetMethod("createDirectory"));
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
            var path = args[0];//.Replace("/", "\\");

            if (File.Exists(path))
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        public LuaTable getDirectoryItems(params string[] args)
        {
            string path = args[0];
            string[] dirs = Directory.GetDirectories(path, "*", SearchOption.AllDirectories);
            lua.NewTable("tmp123");
            LuaTable table = lua["tmp123"] as LuaTable;

            if (dirs.Length > 0)
            {
                foreach (var d in dirs)
                {
                    table[table.Keys.Count] = Path.GetFileName(d);
                }
            }
            else
            {
                foreach (var f in Directory.GetFiles(path))
                {
                    table[table.Keys.Count] = f;
                }
            }

            return table;
        }

        public void createDirectory(params string[] args)
        {
            var path = args[0];

            Directory.CreateDirectory(path);
        }
    }
}