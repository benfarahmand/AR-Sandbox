import com.thomasdiewald.liquidfun.java.DwWorld;
import com.thomasdiewald.liquidfun.java.DwParticleEmitter;
import com.thomasdiewald.pixelflow.java.DwPixelFlow;
import com.thomasdiewald.pixelflow.java.imageprocessing.filter.DwLiquidFX;

import org.jbox2d.collision.shapes.PolygonShape;
import org.jbox2d.collision.shapes.ChainShape;
import org.jbox2d.common.MathUtils;
import org.jbox2d.common.Vec2;
import org.jbox2d.dynamics.Body;
import org.jbox2d.dynamics.BodyDef;
import org.jbox2d.dynamics.BodyType;
import org.jbox2d.dynamics.joints.RevoluteJointDef;
import org.jbox2d.particle.ParticleType;

import processing.core.*;
import processing.opengl.PGraphics2D;

class FluidThread {//extends Topology_Sim3 {

  DwWorld world;

  PGraphics2D pg_particles;
  public boolean UPDATE_PHYSICS = true;
  public boolean USE_DEBUG_DRAW = false;
  public boolean APPLY_LIQUID_FX = false;
  public boolean createParticles = false;
  DwParticleEmitter emitter;
  DwPixelFlow pixelflow;
  DwLiquidFX liquidfx;
  Topology_Sim7_Fluid parent;
  int particle_counter = 0;

  FluidThread(Topology_Sim7_Fluid t) {
    //surface.setLocation(0, 0);
    parent = t;
    pixelflow = new DwPixelFlow(parent);
    liquidfx = new DwLiquidFX(pixelflow);
    pg_particles = (PGraphics2D) createGraphics(width, height, P2D);
    reset();
  }

  void run() {
    try {
      if (UPDATE_PHYSICS) {
        if (createParticles) addParticles();
        world.update();
        influenceFluidParticleVelocity(world);
      }
      drawFluid();
    }
    catch(Exception e) {
      println(e.toString());
    }
  }

  void drawFluid() {
    if (USE_DEBUG_DRAW) {
      PGraphics2D canvas = (PGraphics2D) parent.g;
      canvas.pushMatrix();
      world.applyTransform(canvas);
      world.drawBulletSpawnTrack(canvas);
      world.displayDebugDraw(canvas);
      canvas.popMatrix();
      // DwDebugDraw.display(canvas, world);
    } else {
      PGraphics2D canvas = (PGraphics2D) pg_particles;
      //world.display(canvas);
      canvas.beginDraw();
      canvas.clear();
      world.applyTransform(canvas);
      world.particles.display(canvas, 0);
      canvas.endDraw();
      if (APPLY_LIQUID_FX)
      {
        liquidfx.param.base_LoD = 1;
        liquidfx.param.base_blur_radius = 2;//2;
        liquidfx.param.base_threshold = 0.7f;//0.7f;
        liquidfx.param.highlight_enabled = true;
        liquidfx.param.highlight_LoD = 1;
        liquidfx.param.highlight_decay = 0.6f;//10.0f;//0.6f;
        liquidfx.param.sss_enabled = true;
        liquidfx.param.sss_LoD = 3;
        liquidfx.param.sss_decay = 0.5f;//10.0f;//0.5f;
        liquidfx.apply(canvas);
      }
      image(canvas, 0, 0);
      pushMatrix();
      world.applyTransform(parent.g);
      world.drawBulletSpawnTrack(parent.g);
      popMatrix();
    }
  }

  void influenceFluidParticleVelocity(DwWorld world) {
    Vec2[] p = world.getParticlePositionBuffer();
    Vec2[] v = world.getParticleVelocityBuffer();
    if (p!=null && v!=null) {
      for (int i = 0; i < world.getParticleCount()/*v.length*/; i++) {
        Vec2 p2 = new Vec2();
        world.transform.getBox2screen(p[i].x, p[i].y, p2);
        int x = round(map(p2.x,0,width,0,imagedim[2]));
        int y = round(map(p2.y,0,height,0,imagedim[3]));
        if (!gradientBufferReady) {
          v[i].x=v[i].x+gradients[y*imagedim[2]+x];//*.1;
          v[i].y=v[i].y+gradients[y*imagedim[2]+x+shift];//*.1;
        } else {
          v[i].x=v[i].x+tempGradients[y*imagedim[2]+x];//*.1;
          v[i].y=v[i].y+tempGradients[y*imagedim[2]+x+shift];//*.1;
        }
      }
      //world.setParticleVelocityBuffer(v, world.getParticleCount());
    }
  }

  public void release() {
    if (world != null) world.release(); 
    world = null;
  }
  
  public int getParticleCount(){
    return world.getParticleCount();
  }


  public void reset() {
    // release old resources
    release();

    world = new DwWorld(parent, 18);//18);
    world.setParticleGravityScale(0.0f);
    world.setParticleRadius(0.5f);
    world.setParticleDamping(0.25f);
    world.setParticleDensity(1.2f);
    //world.setParticleMaxCount(500);
    //world.transform.setScreen(0, 0, 1, width, height);

    //setParticleSpawnProperties(spawn_type);

    // create scene: rigid bodies, particles, etc ...
    initScene();
  }

  //////////////////////////////////////////////////////////////////////////////
  // Scene Setup
  //////////////////////////////////////////////////////////////////////////////

  BodyDef bd;
  Body ground;

  public void initScene() {
    emitter = new DwParticleEmitter(world, world.transform);
    //emitter.emit_vel=1;
    float dimx = world.transform.box2d_dimx;
    float dimy = world.transform.box2d_dimy;

    float dimxh = dimx/2;
    float dimyh = dimy/2;
    {
      BodyDef bd = new BodyDef();
      Body ground = world.createBody(bd);

      ChainShape shape = new ChainShape();
      Vec2[] vertices = {new Vec2(-dimxh, 0), new Vec2(dimxh, 0), new Vec2(dimxh, dimy), new Vec2(-dimxh, dimy)};
      shape.createLoop(vertices, 4);
      ground.createFixture(shape, 0.0f);

      world.bodies.add(ground, false, color(0), true, color(0), 1f);
    }
  }

  public void addParticles() {
    emitter.setInScreen( mouseX, mouseY, 300, 40, color(0, 0, 255), ParticleType.b2_waterParticle);

    emitter.emit_vel = 0;//-10;//25 * (sin(particle_counter/200f + PI) * 0.5f  + 0.5f);

    //if (particle_counter % 1 == 0)
    //{
      emitter.emitParticles(2);
    //}
    particle_counter++;
  }
}