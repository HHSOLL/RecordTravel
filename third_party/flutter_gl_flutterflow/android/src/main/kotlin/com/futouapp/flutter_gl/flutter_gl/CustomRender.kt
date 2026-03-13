package com.futouapp.flutter_gl.flutter_gl


import android.opengl.GLES32.*
import android.os.Handler
import android.os.HandlerThread
import android.util.Log
import com.futouapp.threeegl.ThreeEgl
import io.flutter.view.TextureRegistry.SurfaceTextureEntry
import java.util.concurrent.Semaphore


class CustomRender(
    private val entry: SurfaceTextureEntry,
    private val glWidth: Int,
    private val glHeight: Int,
) {
    private val tag = "POC_FLUTTER_GL"

    var disposed = false

    private lateinit var worker: RenderWorker
    private lateinit var eglEnv: EglEnv

    companion object {
        var shareEglEnv: EglEnv? = null
        var dartEglEnv: EglEnv? = null

        var renderThread: HandlerThread? = null
        var renderHandler : Handler? = null
    }

    init {
        if(renderThread == null) {
            renderThread = HandlerThread("flutterGlCustomRender")
            renderThread!!.start()
            renderHandler = Handler(renderThread!!.looper)
        }
        this.executeSync {
            setup()
        }
    }

    fun setup() {
        this.initEGL()

        this.worker = RenderWorker()
        this.worker.setup()
    }

    fun updateTexture(sourceTexture: Int): Boolean {
        this.execute {
            eglEnv.makeCurrent()
            Log.i(
                tag,
                "updateTexture sourceTexture=$sourceTexture currentContext=${android.opengl.EGL14.eglGetCurrentContext()} currentSurface=${android.opengl.EGL14.eglGetCurrentSurface(android.opengl.EGL14.EGL_DRAW)}"
            )

            glBindFramebuffer(GL_FRAMEBUFFER, 0)

            glClearColor(0.0f, 0.0f, 0.0f, 0.0f)
            glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT)

            this.worker.renderTexture(sourceTexture, null)

            glFinish()

            checkGlError()
            eglEnv.swapBuffers()
        }

        return true
    }


    private fun initEGL() {

        if(shareEglEnv == null) {
            shareEglEnv = EglEnv()
            shareEglEnv!!.setupRender()
            ThreeEgl.setContext("shareContext", shareEglEnv!!.eglContext)
        }

        entry.surfaceTexture().setDefaultBufferSize(glWidth, glHeight)
        Log.i(tag, "initEGL glWidth=$glWidth glHeight=$glHeight entryTextureId=${entry.id()}")

        eglEnv = EglEnv()
        eglEnv.setupRender(shareEglEnv!!.eglContext)
        eglEnv.buildWindowSurface(entry.surfaceTexture())
        eglEnv.makeCurrent()
        Log.i(
            tag,
            "windowContext currentContext=${android.opengl.EGL14.eglGetCurrentContext()} currentSurface=${android.opengl.EGL14.eglGetCurrentSurface(android.opengl.EGL14.EGL_DRAW)}"
        )

        if(dartEglEnv == null) {
            dartEglEnv = EglEnv()
            dartEglEnv!!.setupRender(shareEglEnv!!.eglContext)
            dartEglEnv!!.buildOffScreenSurface(glWidth, glHeight)
            Log.i(
                tag,
                "dartOffscreenHandles=${dartEglEnv!!.getEgl()} shareHandles=${shareEglEnv!!.getEgl()} windowHandles=${eglEnv.getEgl()}"
            )
        }
    }


    fun executeSync(task: () -> Unit) {
        val semaphore = Semaphore(0)
        renderHandler!!.post {
            task.invoke()
            semaphore.release()
        }
        semaphore.acquire()
    }

    fun execute(task: () -> Unit) {
        renderHandler!!.post {
            task.invoke()
        }
    }

    fun getEgl() : List<Long> {
        val res = mutableListOf<Long>()

        val egls = this.eglEnv.getEgl().toMutableList()
        val dartEgls = dartEglEnv!!.getEgl().toMutableList()

        res.addAll( egls )
        res.addAll( dartEgls )

        return res
    }

    fun dispose() {
        this.worker.dispose()

        this.eglEnv.dispose()

        dartEglEnv?.dispose()
        dartEglEnv = null

        shareEglEnv?.dispose()
        shareEglEnv = null


        entry.release()

        disposed = true
    }


    private fun checkGlError() {
        val error: Int = glGetError()
        if (error != GL_NO_ERROR) {
            println("ES20_ERROR update texture: glError $error")
            throw RuntimeException("glError $error")
        }
    }
}
