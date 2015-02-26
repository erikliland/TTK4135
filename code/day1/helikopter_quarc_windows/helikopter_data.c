/*
 * helikopter_data.c
 *
 * Real-Time Workshop code generation for Simulink model "helikopter.mdl".
 *
 * Model version              : 1.54
 * Real-Time Workshop version : 7.5  (R2010a)  25-Jan-2010
 * C source code generated on : Thu Feb 26 12:40:30 2015
 *
 * Target selection: quarc_windows.tlc
 * Note: GRT includes extra infrastructure and instrumentation for prototyping
 * Embedded hardware selection: 32-bit Generic
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#include "helikopter.h"
#include "helikopter_private.h"

/* Block parameters (auto storage) */
Parameters_helikopter helikopter_P = {
  1.0,                                 /* Expression: set_other_outputs_at_start
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  0.0,                                 /* Expression: set_other_outputs_at_switch_in
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  1.0,                                 /* Expression: set_other_outputs_at_terminate
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  0.0,                                 /* Expression: set_other_outputs_at_switch_out
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  10.0,                                /* Expression: analog_input_maximums
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  -10.0,                               /* Expression: analog_input_minimums
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  10.0,                                /* Expression: analog_output_maximums
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  -10.0,                               /* Expression: analog_output_minimums
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  0.0,                                 /* Expression: initial_analog_outputs
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  0.0,                                 /* Expression: final_analog_outputs
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  0.0,                                 /* Expression: watchdog_analog_outputs
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  1.6666666666666668E+007,             /* Expression: encoder_filter_frequency
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  1.6276041666666668E+004,             /* Expression: pwm_frequency
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  0.0,                                 /* Expression: initial_pwm_outputs
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  0.0,                                 /* Expression: final_pwm_outputs
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  0.0,                                 /* Expression: watchdog_pwm_outputs
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  -50.0,                               /* Computed Parameter: VandringLavpass_A
                                        * Referenced by: '<S2>/Vandring Lavpass'
                                        */
  50.0,                                /* Computed Parameter: VandringLavpass_C
                                        * Referenced by: '<S2>/Vandring Lavpass'
                                        */
  0.0879,                              /* Expression: KalibPitch
                                        * Referenced by: '<S2>/Kalibrer-Pitch'
                                        */
  0.105,                               /* Expression: KalibElevasjon
                                        * Referenced by: '<S2>/Kalibrer-Elev'
                                        */
  -30.0,                               /* Expression: -30
                                        * Referenced by: '<Root>/Constant'
                                        */
  -0.0879,                             /* Expression: KalibVandring
                                        * Referenced by: '<S2>/Kalibrer -Vandring'
                                        */
  -20.0,                               /* Computed Parameter: VandringDeriv_A
                                        * Referenced by: '<S2>/Vandring Deriv'
                                        */
  -400.0,                              /* Computed Parameter: VandringDeriv_C
                                        * Referenced by: '<S2>/Vandring Deriv'
                                        */
  20.0,                                /* Computed Parameter: VandringDeriv_D
                                        * Referenced by: '<S2>/Vandring Deriv'
                                        */
  -100.0,                              /* Computed Parameter: TransferFcn4_A
                                        * Referenced by: '<S2>/Transfer Fcn4'
                                        */
  -10000.0,                            /* Computed Parameter: TransferFcn4_C
                                        * Referenced by: '<S2>/Transfer Fcn4'
                                        */
  100.0,                               /* Computed Parameter: TransferFcn4_D
                                        * Referenced by: '<S2>/Transfer Fcn4'
                                        */
  -50.0,                               /* Computed Parameter: TransferFcn5_A
                                        * Referenced by: '<S2>/Transfer Fcn5'
                                        */
  -2500.0,                             /* Computed Parameter: TransferFcn5_C
                                        * Referenced by: '<S2>/Transfer Fcn5'
                                        */
  50.0,                                /* Computed Parameter: TransferFcn5_D
                                        * Referenced by: '<S2>/Transfer Fcn5'
                                        */

  /*  Expression: eye(6)*pi/180
   * Referenced by: '<Root>/Gain'
   */
  { 1.7453292519943295E-002, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
    1.7453292519943295E-002, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
    1.7453292519943295E-002, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
    1.7453292519943295E-002, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
    1.7453292519943295E-002, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
    1.7453292519943295E-002 },
  0.0,                                 /* Expression: 0
                                        * Referenced by: '<S1>/Integrator'
                                        */
  0.0,                                 /* Expression: inf
                                        * Referenced by: '<S1>/Integrator'
                                        */
  0.0,                                 /* Expression: -inf
                                        * Referenced by: '<S1>/Integrator'
                                        */
  -10.0,                               /* Expression: -K_ed
                                        * Referenced by: '<S1>/K_ed'
                                        */
  0.0,                                 /* Expression: 0*pi/180
                                        * Referenced by: '<Root>/elevation'
                                        */
  2.3,                                 /* Expression: K_ei
                                        * Referenced by: '<S1>/K_ei'
                                        */
  7.0,                                 /* Expression: K_ep
                                        * Referenced by: '<S1>/K_ep'
                                        */
  10.0,                                /* Expression: 10
                                        * Referenced by: '<S1>/Saturation'
                                        */
  -10.0,                               /* Expression: -10
                                        * Referenced by: '<S1>/Saturation'
                                        */
  0.0,                                 /* Expression: 0*pi/180
                                        * Referenced by: '<Root>/pitch'
                                        */
  8.7266462599716477E-001,             /* Expression: 50*pi/180
                                        * Referenced by: '<S3>/Saturation'
                                        */
  -8.7266462599716477E-001,            /* Expression: -50*pi/180
                                        * Referenced by: '<S3>/Saturation'
                                        */
  2.7967559850093281E+001,             /* Expression: 0.3*K_pp
                                        * Referenced by: '<S3>/K_pp'
                                        */
  1.3184034148827720E+001,             /* Expression: K_pd
                                        * Referenced by: '<S3>/K_pd'
                                        */
  0.6,                                 /* Expression: V_b_eq
                                        * Referenced by: '<S4>/Gain2'
                                        */
  5.0,                                 /* Expression: 5
                                        * Referenced by: '<S2>/Sat B'
                                        */
  -5.0,                                /* Expression: -5
                                        * Referenced by: '<S2>/Sat B'
                                        */
  0.635,                               /* Expression: V_f_eq
                                        * Referenced by: '<S4>/Gain1'
                                        */
  5.0,                                 /* Expression: 5
                                        * Referenced by: '<S2>/Sat'
                                        */
  -5.0,                                /* Expression: -5
                                        * Referenced by: '<S2>/Sat'
                                        */

  /*  Computed Parameter: HILInitialize_CKChannels
   * Referenced by: '<Root>/HIL Initialize'
   */
  { 0, 1 },

  /*  Computed Parameter: HILInitialize_CKModes
   * Referenced by: '<Root>/HIL Initialize'
   */
  { 0, 0 },
  2,                                   /* Computed Parameter: HILInitialize_DOWatchdog
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  0,                                   /* Computed Parameter: HILInitialize_EIInitial
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  0,                                   /* Computed Parameter: HILInitialize_POModes
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */

  /*  Computed Parameter: HILInitialize_AIChannels
   * Referenced by: '<Root>/HIL Initialize'
   */
  { 0U, 1U, 2U, 3U },

  /*  Computed Parameter: HILInitialize_AOChannels
   * Referenced by: '<Root>/HIL Initialize'
   */
  { 0U, 1U, 2U, 3U },

  /*  Computed Parameter: HILInitialize_EIChannels
   * Referenced by: '<Root>/HIL Initialize'
   */
  { 0U, 1U, 2U, 3U },
  4U,                                  /* Computed Parameter: HILInitialize_EIQuadrature
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */

  /*  Computed Parameter: HILReadEncoder_Channels
   * Referenced by: '<S2>/HIL Read Encoder'
   */
  { 0U, 1U, 2U },

  /*  Computed Parameter: HILWriteAnalog_Channels
   * Referenced by: '<S2>/HIL Write Analog'
   */
  { 1U, 0U },
  1,                                   /* Computed Parameter: HILInitialize_Active
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  1,                                   /* Computed Parameter: HILInitialize_CKPStart
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  0,                                   /* Computed Parameter: HILInitialize_CKPEnter
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  1,                                   /* Computed Parameter: HILInitialize_AIPStart
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  0,                                   /* Computed Parameter: HILInitialize_AIPEnter
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  1,                                   /* Computed Parameter: HILInitialize_AOPStart
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  0,                                   /* Computed Parameter: HILInitialize_AOPEnter
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  1,                                   /* Computed Parameter: HILInitialize_AOStart
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  0,                                   /* Computed Parameter: HILInitialize_AOEnter
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  1,                                   /* Computed Parameter: HILInitialize_AOTerminate
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  0,                                   /* Computed Parameter: HILInitialize_AOExit
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  0,                                   /* Computed Parameter: HILInitialize_AOReset
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  0,                                   /* Computed Parameter: HILInitialize_DOPStart
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  0,                                   /* Computed Parameter: HILInitialize_DOPEnter
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  1,                                   /* Computed Parameter: HILInitialize_DOStart
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  0,                                   /* Computed Parameter: HILInitialize_DOEnter
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  1,                                   /* Computed Parameter: HILInitialize_DOTerminate
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  0,                                   /* Computed Parameter: HILInitialize_DOExit
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  0,                                   /* Computed Parameter: HILInitialize_DOReset
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  1,                                   /* Computed Parameter: HILInitialize_EIPStart
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  0,                                   /* Computed Parameter: HILInitialize_EIPEnter
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  1,                                   /* Computed Parameter: HILInitialize_EIStart
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  0,                                   /* Computed Parameter: HILInitialize_EIEnter
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  1,                                   /* Computed Parameter: HILInitialize_POPStart
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  0,                                   /* Computed Parameter: HILInitialize_POPEnter
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  1,                                   /* Computed Parameter: HILInitialize_POStart
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  0,                                   /* Computed Parameter: HILInitialize_POEnter
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  1,                                   /* Computed Parameter: HILInitialize_POTerminate
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  0,                                   /* Computed Parameter: HILInitialize_POExit
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  0,                                   /* Computed Parameter: HILInitialize_POReset
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  0,                                   /* Computed Parameter: HILInitialize_OOReset
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  1,                                   /* Computed Parameter: HILInitialize_DOInitial
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  1,                                   /* Computed Parameter: HILInitialize_DOFinal
                                        * Referenced by: '<Root>/HIL Initialize'
                                        */
  1,                                   /* Computed Parameter: HILReadEncoder_Active
                                        * Referenced by: '<S2>/HIL Read Encoder'
                                        */
  0                                    /* Computed Parameter: HILWriteAnalog_Active
                                        * Referenced by: '<S2>/HIL Write Analog'
                                        */
};
