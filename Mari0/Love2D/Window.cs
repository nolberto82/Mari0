using Microsoft.Xna.Framework;
using NLua;
using System;
using System.Collections.Generic;
using System.Text;

namespace Love2D
{
    public class Window
    {
        private Lua lua;
        private Game game;
        private GraphicsDeviceManager graphics;
        private Graphics gfx;

        public Window(Lua l, Game g, GraphicsDeviceManager gdm, Graphics _gfx)
        {
            lua = l;
            game = g;
            graphics = gdm;
            gfx = _gfx;

            lua.NewTable("love.window");
            lua.RegisterFunction("love.window.setMode", this, typeof(Window).GetMethod("setMode"));
            lua.RegisterFunction("love.window.setTitle", this, typeof(Window).GetMethod("setTitle"));
        }

        public void setMode(params int[] args)
        {
            var w = args[0];
            var h = args[1];

            graphics.PreferredBackBufferWidth = w;
            graphics.PreferredBackBufferHeight = h;
            graphics.ApplyChanges();

            gfx.setScissor();
        }

        public void setTitle(params string[] args)
        {
            var title = args[0];

            game.Window.Title = title;
        }
    }
}
