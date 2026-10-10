/* Minimal KallistiOS + sh4zam smoke test (C API). */
#include <stdio.h>
#include <kos.h>
#include <sh4zam/shz_sh4zam.h>

int main(int argc, char *argv[]) {
    (void)argc; (void)argv;

    /* Show printf output on screen (not just the dcload/serial console). */
    dbgio_dev_select("fb");

    shz_vec4_t v1 = shz_vec4_init(2.0f, 3.0f, 4.0f, 1.0f);
    shz_vec4_t v2 = shz_vec4_normalize(shz_vec4_scale(v1, shz_sinf(SHZ_F_PI * 0.5f)));
    shz_mat4x4_t m;

    /* Load the SH4 back-bank matrix (XMTRX), compose a transform, use it. */
    shz_xmtrx_init_diagonal(1.0f, 1.0f, 1.0f, 1.0f);
    shz_xmtrx_apply_rotation_x(SHZ_F_PI * 0.25f);
    shz_xmtrx_apply_translation(v1.x, v1.y, v1.z);
    shz_xmtrx_store_4x4(&m);

    shz_vec4_t v3 = shz_xmtrx_transform_vec4(v2);

    printf("sh4zam hello\n");
    printf("  normalize(v1) = (%.3f, %.3f, %.3f, %.3f)\n",
           (double)v2.x, (double)v2.y, (double)v2.z, (double)v2.w);
    printf("  dot(v1, v2)   = %.3f\n", (double)shz_vec4_dot(v1, v2));
    printf("  XMTRX * v2    = (%.3f, %.3f, %.3f, %.3f)\n",
           (double)v3.x, (double)v3.y, (double)v3.z, (double)v3.w);

    /* Keep the output visible until Start is pressed. */
    printf("\nPress Start to exit.\n");
    for(;;) {
        maple_device_t *cont = maple_enum_type(0, MAPLE_FUNC_CONTROLLER);
        cont_state_t *st = cont ? (cont_state_t *)maple_dev_status(cont) : NULL;
        if(st && (st->buttons & CONT_START))
            break;
        thd_sleep(50);
    }

    return 0;
}
