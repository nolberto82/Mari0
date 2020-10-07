using Love2D;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework.Input;
using NLua;

namespace Mari0
{
    public partial class Game1 : Game
    {
        public GraphicsDeviceManager graphics;
        public SpriteBatch sb;
        private Lua lua;

        public Game1()
        {
            graphics = new GraphicsDeviceManager(this);
            Content.RootDirectory = "Content";
            IsMouseVisible = true;
        }

        protected override void Initialize()
        {
            // TODO: Add your initialization logic here
            sb = new SpriteBatch(GraphicsDevice);
            Services.AddService(typeof(SpriteBatch), sb);
            LuaLoad();
            base.Initialize();
        }

        protected override void LoadContent()
        {


            // TODO: use this.Content to load your game content here
        }

        protected override void Update(GameTime gameTime)
        {
            var dt = (float)gameTime.ElapsedGameTime.TotalSeconds;

            LuaUpdate(dt);

            base.Update(gameTime);
        }

        protected override void Draw(GameTime gameTime)
        {
            LuaDraw();

            base.Draw(gameTime);
        }
    }
}
