using Microsoft.Xna.Framework;
using System;
using System.Collections.Generic;
using System.Text;
using NLua;
using System.IO;
using System.Collections.Specialized;
using System.Collections;
using System.Linq;
using Microsoft.Xna.Framework.Graphics;

namespace Mari0
{
    public partial class Game1 : Game
    {
        //Lua lua;

        void MainLoad()
        {
            Directory.SetCurrentDirectory(Environment.CurrentDirectory + "\\Content\\lua");
            lua = new Lua();
            lua.DoString("package.path = package.path .. ';/Content/lua/?.lua'");
            lua.DoFile("main.lua");
            lua.DoFile("quad.lua");
            lua.GetFunction("mainload").Call();


            ChangeScale(lua["scale"]);

            lua["fontimage"] = newImage("graphics/smb/font");
            var fontglyphs = lua["fontglyphs"];
            var fontquads = lua["fontquads"] as LuaTable;
            for (int i = 0; i < fontglyphs.ToString().Length; i++)
            {
                fontquads[fontglyphs.ToString()[i]] = newQuad(i * 8, 0, 8, 8);
            }
            lua["fontquads"] = fontquads;

            var graphicspack = lua["graphicspack"];

            var smbtilesimg = lua["smbtilesimg"] = newImage("graphics/" + graphicspack + "/smbtiles");
            var portaltilesimg = lua["portaltilesimg"] = newImage("graphics/" + graphicspack + "/portaltiles");
            var entitiesimg = lua["entitiesimg"] = newImage("graphics/" + graphicspack + "/entities");

            var tilequads = lua["tilequads"] as LuaTable;

            var width = (smbtilesimg as Texture2D).Width / 17;
            var height = (smbtilesimg as Texture2D).Height / 17;

            for (int y=0;y<height;y++)
            {
                for (int x = 0; x < width; x++)
                {
                    //tilequads[tilequads.Keys.Count] = lua.GetFunction("quad:new").Call(smbtilesimg,)
                }
            }
        }

        void MainDraw()
        {
            GraphicsDevice.Clear(GetBackgroundColor(1));
            //DrawString("mario", 8, 8);
        }

        Color GetBackgroundColor(int index)
        {
            var t1 = lua.GetTable("backgroundcolor");
            var color = t1[index] as LuaTable;

            float r = Convert.ToSingle(color[1]);
            float g = Convert.ToSingle(color[2]);
            float b = Convert.ToSingle(color[3]);
            Color c = new Color(r, g, b);
            return c;
        }

        void DrawString(object str, float x, float y)
        {
            var startx = x;
            var fontquads = (LuaTable)lua["fontquads"];
            var scale = Convert.ToSingle(lua["scale"]);
            var fontimage = (Texture2D)lua["fontimage"];

            string s = str.ToString();
            for (int i = 0; i < s.Length; i++)
            {
                char c = s[i];
                if (c == '|')
                {
                    x = startx - (i * 8);
                    y += 10;
                }
                else if (fontquads[c] != null)
                {
                    sb.Draw(fontimage, new Vector2((x + i * 8) * scale, y * scale), (Rectangle)fontquads[c], Color.White, 0, Vector2.Zero, scale, SpriteEffects.None, 1);
                }
            }
        }

        Texture2D newImage(string path)
        {
            return Content.Load<Texture2D>(path);
        }

        Rectangle newQuad(int x, int y, int w, int h)
        {
            return new Rectangle(x, y, w, h);
        }

        void ChangeScale(object s)
        {
            var scale = Convert.ToInt32(s);
            graphics.PreferredBackBufferWidth = 400 * scale;
            graphics.PreferredBackBufferHeight = 224 * scale;
            graphics.ApplyChanges();
        }
    }
}
