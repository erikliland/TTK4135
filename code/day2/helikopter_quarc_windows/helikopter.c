/*
 * helikopter.c
 *
 * Real-Time Workshop code generation for Simulink model "helikopter.mdl".
 *
 * Model version              : 1.55
 * Real-Time Workshop version : 7.5  (R2010a)  25-Jan-2010
 * C source code generated on : Thu Feb 26 13:18:12 2015
 *
 * Target selection: quarc_windows.tlc
 * Note: GRT includes extra infrastructure and instrumentation for prototyping
 * Embedded hardware selection: 32-bit Generic
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#include "helikopter.h"
#include "helikopter_private.h"
#include <stdio.h>
#include "helikopter_dt.h"

/* Block signals (auto storage) */
BlockIO_helikopter helikopter_B;

/* Continuous states */
ContinuousStates_helikopter helikopter_X;

/* Block states (auto storage) */
D_Work_helikopter helikopter_DWork;

/* Real-time model */
RT_MODEL_helikopter helikopter_M_;
RT_MODEL_helikopter *helikopter_M = &helikopter_M_;

/*
 * Writes out MAT-file header.  Returns success or failure.
 * Returns:
 *      0 - success
 *      1 - failure
 */
int_T rt_WriteMat4FileHeader(FILE *fp, int32_T m, int32_T n, const char *name)
{
  typedef enum { ELITTLE_ENDIAN, EBIG_ENDIAN } ByteOrder;

  int16_T one = 1;
  ByteOrder byteOrder = (*((int8_T *)&one)==1) ? ELITTLE_ENDIAN : EBIG_ENDIAN;
  int32_T type = (byteOrder == ELITTLE_ENDIAN) ? 0: 1000;
  int32_T imagf = 0;
  int32_T name_len = strlen(name) + 1;
  if ((fwrite(&type, sizeof(int32_T), 1, fp) == 0) ||
      (fwrite(&m, sizeof(int32_T), 1, fp) == 0) ||
      (fwrite(&n, sizeof(int32_T), 1, fp) == 0) ||
      (fwrite(&imagf, sizeof(int32_T), 1, fp) == 0) ||
      (fwrite(&name_len, sizeof(int32_T), 1, fp) == 0) ||
      (fwrite(name, sizeof(char), name_len, fp) == 0)) {
    return(1);
  } else {
    return(0);
  }
}                                      /* end rt_WriteMat4FileHeader */

/*
 * This function updates continuous states using the ODE1 fixed-step
 * solver algorithm
 */
static void rt_ertODEUpdateContinuousStates(RTWSolverInfo *si )
{
  time_T tnew = rtsiGetSolverStopTime(si);
  time_T h = rtsiGetStepSize(si);
  real_T *x = rtsiGetContStates(si);
  ODE1_IntgData *id = (ODE1_IntgData *)rtsiGetSolverData(si);
  real_T *f0 = id->f[0];
  int_T i;
  int_T nXc = 5;
  rtsiSetSimTimeStep(si,MINOR_TIME_STEP);
  rtsiSetdX(si, f0);
  helikopter_derivatives();
  rtsiSetT(si, tnew);
  for (i = 0; i < nXc; i++) {
    *x += h * f0[i];
    x++;
  }

  rtsiSetSimTimeStep(si,MAJOR_TIME_STEP);
}

/* Model output function */
void helikopter_output(int_T tid)
{
  /* local block i/o variables */
  real_T rtb_HILReadEncoder_o1;
  real_T rtb_HILReadEncoder_o2;
  real_T rtb_HILReadEncoder_o3;
  real_T rtb_Gain2;
  real_T rtb_Sum;
  real_T rtb_Gain1;
  real_T tmp[6];
  int32_T tmp_0;
  int32_T tmp_1;
  if (rtmIsMajorTimeStep(helikopter_M)) {
    /* set solver stop time */
    if (!(helikopter_M->Timing.clockTick0+1)) {
      rtsiSetSolverStopTime(&helikopter_M->solverInfo,
                            ((helikopter_M->Timing.clockTickH0 + 1) *
        helikopter_M->Timing.stepSize0 * 4294967296.0));
    } else {
      rtsiSetSolverStopTime(&helikopter_M->solverInfo,
                            ((helikopter_M->Timing.clockTick0 + 1) *
        helikopter_M->Timing.stepSize0 + helikopter_M->Timing.clockTickH0 *
        helikopter_M->Timing.stepSize0 * 4294967296.0));
    }
  }                                    /* end MajorTimeStep */

  /* Update absolute time of base rate at minor time step */
  if (rtmIsMinorTimeStep(helikopter_M)) {
    helikopter_M->Timing.t[0] = rtsiGetT(&helikopter_M->solverInfo);
  }

  if (rtmIsMajorTimeStep(helikopter_M)) {
  }

  /* TransferFcn: '<S2>/Vandring Lavpass' */
  helikopter_B.VandringLavpass = helikopter_P.VandringLavpass_C*
    helikopter_X.VandringLavpass_CSTATE;
  if (rtmIsMajorTimeStep(helikopter_M)) {
    /* S-Function (hil_read_encoder_block): '<S2>/HIL Read Encoder' */

    /* S-Function Block: helikopter/Heli 3D/HIL Read Encoder (hil_read_encoder_block) */
    {
      t_error result = hil_read_encoder(helikopter_DWork.HILInitialize_Card,
        helikopter_P.HILReadEncoder_Channels, 3,
        &helikopter_DWork.HILReadEncoder_Buffer[0]);
      if (result < 0) {
        msg_get_error_messageA(NULL, result, _rt_error_message, sizeof
          (_rt_error_message));
        rtmSetErrorStatus(helikopter_M, _rt_error_message);
      } else {
        rtb_HILReadEncoder_o1 = helikopter_DWork.HILReadEncoder_Buffer[0];
        rtb_HILReadEncoder_o2 = helikopter_DWork.HILReadEncoder_Buffer[1];
        rtb_HILReadEncoder_o3 = helikopter_DWork.HILReadEncoder_Buffer[2];
      }
    }

    /* Gain: '<S2>/Kalibrer-Pitch' */
    helikopter_B.KalibrerPitch = helikopter_P.KalibrerPitch_Gain *
      rtb_HILReadEncoder_o2;

    /* Gain: '<S2>/Kalibrer-Elev' */
    helikopter_B.KalibrerElev = helikopter_P.KalibrerElev_Gain *
      rtb_HILReadEncoder_o3;

    /* Sum: '<Root>/Add' incorporates:
     *  Constant: '<Root>/Constant'
     */
    helikopter_B.Add = helikopter_B.KalibrerElev + helikopter_P.Constant_Value;

    /* Gain: '<S2>/Kalibrer -Vandring' */
    helikopter_B.KalibrerVandring = helikopter_P.KalibrerVandring_Gain *
      rtb_HILReadEncoder_o1;
  }

  /* TransferFcn: '<S2>/Vandring Deriv' */
  rtb_Gain2 = helikopter_P.VandringDeriv_D*helikopter_B.KalibrerVandring;
  rtb_Gain2 += helikopter_P.VandringDeriv_C*helikopter_X.VandringDeriv_CSTATE;

  /* TransferFcn: '<S2>/Transfer Fcn4' */
  rtb_Sum = helikopter_P.TransferFcn4_D*helikopter_B.KalibrerPitch;
  rtb_Sum += helikopter_P.TransferFcn4_C*helikopter_X.TransferFcn4_CSTATE;

  /* TransferFcn: '<S2>/Transfer Fcn5' */
  rtb_Gain1 = helikopter_P.TransferFcn5_D*helikopter_B.KalibrerElev;
  rtb_Gain1 += helikopter_P.TransferFcn5_C*helikopter_X.TransferFcn5_CSTATE;

  /* Gain: '<Root>/Gain' incorporates:
   *  SignalConversion: '<Root>/TmpSignal ConversionAtGainInport1'
   */
  tmp[0] = helikopter_B.VandringLavpass;
  tmp[1] = rtb_Gain2;
  tmp[2] = helikopter_B.KalibrerPitch;
  tmp[3] = rtb_Sum;
  tmp[4] = helikopter_B.Add;
  tmp[5] = rtb_Gain1;
  for (tmp_0 = 0; tmp_0 < 6; tmp_0++) {
    helikopter_B.Gain[tmp_0] = 0.0;
    for (tmp_1 = 0; tmp_1 < 6; tmp_1++) {
      helikopter_B.Gain[tmp_0] = helikopter_P.Gain_Gain[6 * tmp_1 + tmp_0] *
        tmp[tmp_1] + helikopter_B.Gain[tmp_0];
    }
  }

  if (rtmIsMajorTimeStep(helikopter_M)) {
    /* ToFile: '<Root>/To File1' */
    if (rtmIsMajorTimeStep(helikopter_M)) {
      if (!(++helikopter_DWork.ToFile1_IWORK.Decimation % 1) &&
          (helikopter_DWork.ToFile1_IWORK.Count*7)+1 < 100000000 ) {
        FILE *fp = (FILE *) helikopter_DWork.ToFile1_PWORK.FilePtr;
        if (fp != (NULL)) {
          real_T u[7];
          helikopter_DWork.ToFile1_IWORK.Decimation = 0;
          u[0] = helikopter_M->Timing.t[1];
          u[1] = helikopter_B.Gain[0];
          u[2] = helikopter_B.Gain[1];
          u[3] = helikopter_B.Gain[2];
          u[4] = helikopter_B.Gain[3];
          u[5] = helikopter_B.Gain[4];
          u[6] = helikopter_B.Gain[5];
          if (fwrite(u, sizeof(real_T), 7, fp) != 7) {
            rtmSetErrorStatus(helikopter_M,
                              "Error writing to MAT-file measurements.mat");
            return;
          }

          if (((++helikopter_DWork.ToFile1_IWORK.Count)*7)+1 >= 100000000) {
            (void)fprintf(stdout,
                          "*** The ToFile block will stop logging data before\n"
                          "    the simulation has ended, because it has reached\n"
                          "    the maximum number of elements (100000000)\n"
                          "    allowed in MAT-file measurements.mat.\n");
          }
        }
      }
    }
  }

  /* Integrator: '<S1>/Integrator'
   *
   * Regarding '<S1>/Integrator':
   *  Limited Integrator
   */
  if (helikopter_X.Integrator_CSTATE >= helikopter_P.Integrator_UpperSat ) {
    helikopter_X.Integrator_CSTATE = helikopter_P.Integrator_UpperSat;
  } else if (helikopter_X.Integrator_CSTATE <= helikopter_P.Integrator_LowerSat )
  {
    helikopter_X.Integrator_CSTATE = helikopter_P.Integrator_LowerSat;
  }

  rtb_Gain1 = helikopter_X.Integrator_CSTATE;

  /* Sum: '<S1>/Sum' incorporates:
   *  Constant: '<Root>/elevation ref'
   */
  rtb_Sum = helikopter_P.elevationref_Value - helikopter_B.Gain[4];

  /* Gain: '<S1>/K_ei' */
  helikopter_B.K_ei = helikopter_P.K_ei_Gain * rtb_Sum;

  /* Sum: '<S1>/Sum1' incorporates:
   *  Gain: '<S1>/K_ed'
   *  Gain: '<S1>/K_ep'
   */
  rtb_Gain1 = (helikopter_P.K_ep_Gain * rtb_Sum + rtb_Gain1) +
    helikopter_P.K_ed_Gain * helikopter_B.Gain[5];

  /* Saturate: '<S1>/Saturation' */
  rtb_Gain1 = rt_SATURATE(rtb_Gain1, helikopter_P.Saturation_LowerSat,
    helikopter_P.Saturation_UpperSat);

  /* FromWorkspace: '<Root>/From Workspace' */
  {
    real_T *pDataValues = (real_T *)
      helikopter_DWork.FromWorkspace_PWORK.DataPtr;
    real_T *pTimeValues = (real_T *)
      helikopter_DWork.FromWorkspace_PWORK.TimePtr;
    int_T currTimeIndex = helikopter_DWork.FromWorkspace_IWORK.PrevIndex;
    real_T t = helikopter_M->Timing.t[0];

    /* get index */
    if (t <= pTimeValues[0]) {
      currTimeIndex = 0;
    } else if (t >= pTimeValues[99]) {
      currTimeIndex = 98;
    } else {
      if (t < pTimeValues[currTimeIndex]) {
        while (t < pTimeValues[currTimeIndex]) {
          currTimeIndex--;
        }
      } else {
        while (t >= pTimeValues[currTimeIndex + 1]) {
          currTimeIndex++;
        }
      }
    }

    helikopter_DWork.FromWorkspace_IWORK.PrevIndex = currTimeIndex;

    /* post output */
    {
      real_T t1 = pTimeValues[currTimeIndex];
      real_T t2 = pTimeValues[currTimeIndex + 1];
      if (t1 == t2) {
        if (t < t1) {
          rtb_Sum = pDataValues[currTimeIndex];
        } else {
          rtb_Sum = pDataValues[currTimeIndex + 1];
        }
      } else {
        real_T f1 = (t2 - t) / (t2 - t1);
        real_T f2 = 1.0 - f1;
        real_T d1;
        real_T d2;
        int_T TimeIndex= currTimeIndex;
        d1 = pDataValues[TimeIndex];
        d2 = pDataValues[TimeIndex + 1];
        rtb_Sum = (real_T) rtInterpolate(d1, d2, f1, f2);
        pDataValues += 100;
      }
    }
  }

  if (rtmIsMajorTimeStep(helikopter_M)) {
  }

  /* Sum: '<S3>/Sum' incorporates:
   *  Gain: '<S3>/K_pd'
   *  Gain: '<S3>/K_pp'
   *  Saturate: '<S3>/Saturation'
   *  Sum: '<S3>/Sum1'
   */
  rtb_Sum = (rt_SATURATE(rtb_Sum, helikopter_P.Saturation_LowerSat_m,
              helikopter_P.Saturation_UpperSat_c) - helikopter_B.Gain[2]) *
    helikopter_P.K_pp_Gain - helikopter_P.K_pd_Gain * helikopter_B.Gain[3];

  /* Gain: '<S4>/Gain2' incorporates:
   *  Sum: '<S4>/Sum4'
   */
  rtb_Gain2 = (rtb_Gain1 - rtb_Sum) * helikopter_P.Gain2_Gain;

  /* Saturate: '<S2>/Sat B' */
  helikopter_B.SatB = rt_SATURATE(rtb_Gain2, helikopter_P.SatB_LowerSat,
    helikopter_P.SatB_UpperSat);
  if (rtmIsMajorTimeStep(helikopter_M)) {
  }

  /* Gain: '<S4>/Gain1' incorporates:
   *  Sum: '<S4>/Sum3'
   */
  rtb_Gain1 = (rtb_Sum + rtb_Gain1) * helikopter_P.Gain1_Gain;

  /* Saturate: '<S2>/Sat' */
  helikopter_B.Sat = rt_SATURATE(rtb_Gain1, helikopter_P.Sat_LowerSat,
    helikopter_P.Sat_UpperSat);
  if (rtmIsMajorTimeStep(helikopter_M)) {
    /* S-Function (hil_write_analog_block): '<S2>/HIL Write Analog' */

    /* S-Function Block: helikopter/Heli 3D/HIL Write Analog (hil_write_analog_block) */
    {
      t_error result;
      helikopter_DWork.HILWriteAnalog_Buffer[0] = helikopter_B.SatB;
      helikopter_DWork.HILWriteAnalog_Buffer[1] = helikopter_B.Sat;
      result = hil_write_analog(helikopter_DWork.HILInitialize_Card,
        helikopter_P.HILWriteAnalog_Channels, 2,
        &helikopter_DWork.HILWriteAnalog_Buffer[0]);
      if (result < 0) {
        msg_get_error_messageA(NULL, result, _rt_error_message, sizeof
          (_rt_error_message));
        rtmSetErrorStatus(helikopter_M, _rt_error_message);
      }
    }
  }

  /* tid is required for a uniform function interface.
   * Argument tid is not used in the function. */
  UNUSED_PARAMETER(tid);
}

/* Model update function */
void helikopter_update(int_T tid)
{
  if (rtmIsMajorTimeStep(helikopter_M)) {
    rt_ertODEUpdateContinuousStates(&helikopter_M->solverInfo);
  }

  /* Update absolute time for base rate */
  /* The "clockTick0" counts the number of times the code of this task has
   * been executed. The absolute time is the multiplication of "clockTick0"
   * and "Timing.stepSize0". Size of "clockTick0" ensures timer will not
   * overflow during the application lifespan selected.
   * Timer of this task consists of two 32 bit unsigned integers.
   * The two integers represent the low bits Timing.clockTick0 and the high bits
   * Timing.clockTickH0. When the low bit overflows to 0, the high bits increment.
   */
  if (!(++helikopter_M->Timing.clockTick0)) {
    ++helikopter_M->Timing.clockTickH0;
  }

  helikopter_M->Timing.t[0] = rtsiGetSolverStopTime(&helikopter_M->solverInfo);
  if (rtmIsMajorTimeStep(helikopter_M)) {
    /* Update absolute timer for sample time: [0.001s, 0.0s] */
    /* The "clockTick1" counts the number of times the code of this task has
     * been executed. The absolute time is the multiplication of "clockTick1"
     * and "Timing.stepSize1". Size of "clockTick1" ensures timer will not
     * overflow during the application lifespan selected.
     * Timer of this task consists of two 32 bit unsigned integers.
     * The two integers represent the low bits Timing.clockTick1 and the high bits
     * Timing.clockTickH1. When the low bit overflows to 0, the high bits increment.
     */
    if (!(++helikopter_M->Timing.clockTick1)) {
      ++helikopter_M->Timing.clockTickH1;
    }

    helikopter_M->Timing.t[1] = helikopter_M->Timing.clockTick1 *
      helikopter_M->Timing.stepSize1 + helikopter_M->Timing.clockTickH1 *
      helikopter_M->Timing.stepSize1 * 4294967296.0;
  }

  /* tid is required for a uniform function interface.
   * Argument tid is not used in the function. */
  UNUSED_PARAMETER(tid);
}

/* Derivatives for root system: '<Root>' */
void helikopter_derivatives(void)
{
  /* Derivatives for TransferFcn: '<S2>/Vandring Lavpass' */
  {
    ((StateDerivatives_helikopter *) helikopter_M->ModelData.derivs)
      ->VandringLavpass_CSTATE = helikopter_B.KalibrerVandring;
    ((StateDerivatives_helikopter *) helikopter_M->ModelData.derivs)
      ->VandringLavpass_CSTATE += (helikopter_P.VandringLavpass_A)*
      helikopter_X.VandringLavpass_CSTATE;
  }

  /* Derivatives for TransferFcn: '<S2>/Vandring Deriv' */
  {
    ((StateDerivatives_helikopter *) helikopter_M->ModelData.derivs)
      ->VandringDeriv_CSTATE = helikopter_B.KalibrerVandring;
    ((StateDerivatives_helikopter *) helikopter_M->ModelData.derivs)
      ->VandringDeriv_CSTATE += (helikopter_P.VandringDeriv_A)*
      helikopter_X.VandringDeriv_CSTATE;
  }

  /* Derivatives for TransferFcn: '<S2>/Transfer Fcn4' */
  {
    ((StateDerivatives_helikopter *) helikopter_M->ModelData.derivs)
      ->TransferFcn4_CSTATE = helikopter_B.KalibrerPitch;
    ((StateDerivatives_helikopter *) helikopter_M->ModelData.derivs)
      ->TransferFcn4_CSTATE += (helikopter_P.TransferFcn4_A)*
      helikopter_X.TransferFcn4_CSTATE;
  }

  /* Derivatives for TransferFcn: '<S2>/Transfer Fcn5' */
  {
    ((StateDerivatives_helikopter *) helikopter_M->ModelData.derivs)
      ->TransferFcn5_CSTATE = helikopter_B.KalibrerElev;
    ((StateDerivatives_helikopter *) helikopter_M->ModelData.derivs)
      ->TransferFcn5_CSTATE += (helikopter_P.TransferFcn5_A)*
      helikopter_X.TransferFcn5_CSTATE;
  }

  /* Derivatives for Integrator: '<S1>/Integrator' */
  {
    boolean_T lsat;
    boolean_T usat;
    lsat = ( helikopter_X.Integrator_CSTATE <= helikopter_P.Integrator_LowerSat );
    usat = ( helikopter_X.Integrator_CSTATE >= helikopter_P.Integrator_UpperSat );
    if ((!lsat && !usat) ||
        (lsat && (helikopter_B.K_ei > 0)) ||
        (usat && (helikopter_B.K_ei < 0)) ) {
      ((StateDerivatives_helikopter *) helikopter_M->ModelData.derivs)
        ->Integrator_CSTATE = helikopter_B.K_ei;
    } else {
      /* in saturation */
      ((StateDerivatives_helikopter *) helikopter_M->ModelData.derivs)
        ->Integrator_CSTATE = 0.0;
    }
  }
}

/* Model initialize function */
void helikopter_initialize(boolean_T firstTime)
{
  (void)firstTime;

  /* Registration code */

  /* initialize non-finites */
  rt_InitInfAndNaN(sizeof(real_T));

  /* non-finite (run-time) assignments */
  helikopter_P.Integrator_UpperSat = rtInf;
  helikopter_P.Integrator_LowerSat = rtMinusInf;

  /* initialize real-time model */
  (void) memset((void *)helikopter_M, 0,
                sizeof(RT_MODEL_helikopter));

  {
    /* Setup solver object */
    rtsiSetSimTimeStepPtr(&helikopter_M->solverInfo,
                          &helikopter_M->Timing.simTimeStep);
    rtsiSetTPtr(&helikopter_M->solverInfo, &rtmGetTPtr(helikopter_M));
    rtsiSetStepSizePtr(&helikopter_M->solverInfo,
                       &helikopter_M->Timing.stepSize0);
    rtsiSetdXPtr(&helikopter_M->solverInfo, &helikopter_M->ModelData.derivs);
    rtsiSetContStatesPtr(&helikopter_M->solverInfo,
                         &helikopter_M->ModelData.contStates);
    rtsiSetNumContStatesPtr(&helikopter_M->solverInfo,
      &helikopter_M->Sizes.numContStates);
    rtsiSetErrorStatusPtr(&helikopter_M->solverInfo, (&rtmGetErrorStatus
      (helikopter_M)));
    rtsiSetRTModelPtr(&helikopter_M->solverInfo, helikopter_M);
  }

  rtsiSetSimTimeStep(&helikopter_M->solverInfo, MAJOR_TIME_STEP);
  helikopter_M->ModelData.intgData.f[0] = helikopter_M->ModelData.odeF[0];
  helikopter_M->ModelData.contStates = ((real_T *) &helikopter_X);
  rtsiSetSolverData(&helikopter_M->solverInfo, (void *)
                    &helikopter_M->ModelData.intgData);
  rtsiSetSolverName(&helikopter_M->solverInfo,"ode1");

  /* Initialize timing info */
  {
    int_T *mdlTsMap = helikopter_M->Timing.sampleTimeTaskIDArray;
    mdlTsMap[0] = 0;
    mdlTsMap[1] = 1;
    helikopter_M->Timing.sampleTimeTaskIDPtr = (&mdlTsMap[0]);
    helikopter_M->Timing.sampleTimes = (&helikopter_M->Timing.sampleTimesArray[0]);
    helikopter_M->Timing.offsetTimes = (&helikopter_M->Timing.offsetTimesArray[0]);

    /* task periods */
    helikopter_M->Timing.sampleTimes[0] = (0.0);
    helikopter_M->Timing.sampleTimes[1] = (0.001);

    /* task offsets */
    helikopter_M->Timing.offsetTimes[0] = (0.0);
    helikopter_M->Timing.offsetTimes[1] = (0.0);
  }

  rtmSetTPtr(helikopter_M, &helikopter_M->Timing.tArray[0]);

  {
    int_T *mdlSampleHits = helikopter_M->Timing.sampleHitArray;
    mdlSampleHits[0] = 1;
    mdlSampleHits[1] = 1;
    helikopter_M->Timing.sampleHits = (&mdlSampleHits[0]);
  }

  rtmSetTFinal(helikopter_M, -1);
  helikopter_M->Timing.stepSize0 = 0.001;
  helikopter_M->Timing.stepSize1 = 0.001;

  /* external mode info */
  helikopter_M->Sizes.checksums[0] = (719090587U);
  helikopter_M->Sizes.checksums[1] = (3806678599U);
  helikopter_M->Sizes.checksums[2] = (2578513878U);
  helikopter_M->Sizes.checksums[3] = (947146749U);

  {
    static const sysRanDType rtAlwaysEnabled = SUBSYS_RAN_BC_ENABLE;
    static RTWExtModeInfo rt_ExtModeInfo;
    static const sysRanDType *systemRan[1];
    helikopter_M->extModeInfo = (&rt_ExtModeInfo);
    rteiSetSubSystemActiveVectorAddresses(&rt_ExtModeInfo, systemRan);
    systemRan[0] = &rtAlwaysEnabled;
    rteiSetModelMappingInfoPtr(helikopter_M->extModeInfo,
      &helikopter_M->SpecialInfo.mappingInfo);
    rteiSetChecksumsPtr(helikopter_M->extModeInfo, helikopter_M->Sizes.checksums);
    rteiSetTPtr(helikopter_M->extModeInfo, rtmGetTPtr(helikopter_M));
  }

  helikopter_M->solverInfoPtr = (&helikopter_M->solverInfo);
  helikopter_M->Timing.stepSize = (0.001);
  rtsiSetFixedStepSize(&helikopter_M->solverInfo, 0.001);
  rtsiSetSolverMode(&helikopter_M->solverInfo, SOLVER_MODE_SINGLETASKING);

  /* block I/O */
  helikopter_M->ModelData.blockIO = ((void *) &helikopter_B);

  {
    int_T i;
    for (i = 0; i < 6; i++) {
      helikopter_B.Gain[i] = 0.0;
    }

    helikopter_B.VandringLavpass = 0.0;
    helikopter_B.KalibrerPitch = 0.0;
    helikopter_B.KalibrerElev = 0.0;
    helikopter_B.Add = 0.0;
    helikopter_B.KalibrerVandring = 0.0;
    helikopter_B.K_ei = 0.0;
    helikopter_B.SatB = 0.0;
    helikopter_B.Sat = 0.0;
  }

  /* parameters */
  helikopter_M->ModelData.defaultParam = ((real_T *)&helikopter_P);

  /* states (continuous) */
  {
    real_T *x = (real_T *) &helikopter_X;
    helikopter_M->ModelData.contStates = (x);
    (void) memset((void *)&helikopter_X, 0,
                  sizeof(ContinuousStates_helikopter));
  }

  /* states (dwork) */
  helikopter_M->Work.dwork = ((void *) &helikopter_DWork);
  (void) memset((void *)&helikopter_DWork, 0,
                sizeof(D_Work_helikopter));
  helikopter_DWork.HILInitialize_AIMinimums[0] = 0.0;
  helikopter_DWork.HILInitialize_AIMinimums[1] = 0.0;
  helikopter_DWork.HILInitialize_AIMinimums[2] = 0.0;
  helikopter_DWork.HILInitialize_AIMinimums[3] = 0.0;
  helikopter_DWork.HILInitialize_AIMaximums[0] = 0.0;
  helikopter_DWork.HILInitialize_AIMaximums[1] = 0.0;
  helikopter_DWork.HILInitialize_AIMaximums[2] = 0.0;
  helikopter_DWork.HILInitialize_AIMaximums[3] = 0.0;
  helikopter_DWork.HILInitialize_AOMinimums[0] = 0.0;
  helikopter_DWork.HILInitialize_AOMinimums[1] = 0.0;
  helikopter_DWork.HILInitialize_AOMinimums[2] = 0.0;
  helikopter_DWork.HILInitialize_AOMinimums[3] = 0.0;
  helikopter_DWork.HILInitialize_AOMaximums[0] = 0.0;
  helikopter_DWork.HILInitialize_AOMaximums[1] = 0.0;
  helikopter_DWork.HILInitialize_AOMaximums[2] = 0.0;
  helikopter_DWork.HILInitialize_AOMaximums[3] = 0.0;
  helikopter_DWork.HILInitialize_AOVoltages[0] = 0.0;
  helikopter_DWork.HILInitialize_AOVoltages[1] = 0.0;
  helikopter_DWork.HILInitialize_AOVoltages[2] = 0.0;
  helikopter_DWork.HILInitialize_AOVoltages[3] = 0.0;
  helikopter_DWork.HILInitialize_FilterFrequency[0] = 0.0;
  helikopter_DWork.HILInitialize_FilterFrequency[1] = 0.0;
  helikopter_DWork.HILInitialize_FilterFrequency[2] = 0.0;
  helikopter_DWork.HILInitialize_FilterFrequency[3] = 0.0;
  helikopter_DWork.HILWriteAnalog_Buffer[0] = 0.0;
  helikopter_DWork.HILWriteAnalog_Buffer[1] = 0.0;

  /* data type transition information */
  {
    static DataTypeTransInfo dtInfo;
    (void) memset((char_T *) &dtInfo, 0,
                  sizeof(dtInfo));
    helikopter_M->SpecialInfo.mappingInfo = (&dtInfo);
    dtInfo.numDataTypes = 15;
    dtInfo.dataTypeSizes = &rtDataTypeSizes[0];
    dtInfo.dataTypeNames = &rtDataTypeNames[0];

    /* Block I/O transition table */
    dtInfo.B = &rtBTransTable;

    /* Parameters transition table */
    dtInfo.P = &rtPTransTable;
  }
}

/* Model terminate function */
void helikopter_terminate(void)
{
  /* Terminate for S-Function (hil_initialize_block): '<Root>/HIL Initialize' */

  /* S-Function Block: helikopter/HIL Initialize (hil_initialize_block) */
  {
    t_boolean is_switching;
    t_int result;
    hil_task_stop_all(helikopter_DWork.HILInitialize_Card);
    hil_task_delete_all(helikopter_DWork.HILInitialize_Card);
    hil_monitor_stop_all(helikopter_DWork.HILInitialize_Card);
    hil_monitor_delete_all(helikopter_DWork.HILInitialize_Card);
    is_switching = false;
    if ((helikopter_P.HILInitialize_AOTerminate && !is_switching) ||
        (helikopter_P.HILInitialize_AOExit && is_switching)) {
      helikopter_DWork.HILInitialize_AOVoltages[0] =
        helikopter_P.HILInitialize_AOFinal;
      helikopter_DWork.HILInitialize_AOVoltages[1] =
        helikopter_P.HILInitialize_AOFinal;
      helikopter_DWork.HILInitialize_AOVoltages[2] =
        helikopter_P.HILInitialize_AOFinal;
      helikopter_DWork.HILInitialize_AOVoltages[3] =
        helikopter_P.HILInitialize_AOFinal;
      result = hil_write_analog(helikopter_DWork.HILInitialize_Card,
        &helikopter_P.HILInitialize_AOChannels[0], 4U,
        &helikopter_DWork.HILInitialize_AOVoltages[0]);
      if (result < 0) {
        msg_get_error_messageA(NULL, result, _rt_error_message, sizeof
          (_rt_error_message));
        rtmSetErrorStatus(helikopter_M, _rt_error_message);
      }
    }

    hil_close(helikopter_DWork.HILInitialize_Card);
    helikopter_DWork.HILInitialize_Card = NULL;
  }

  /* Terminate for ToFile: '<Root>/To File1' */
  {
    FILE *fp = (FILE *) helikopter_DWork.ToFile1_PWORK.FilePtr;
    if (fp != (NULL)) {
      const char *fileName = "measurements.mat";
      if (fclose(fp) == EOF) {
        rtmSetErrorStatus(helikopter_M,
                          "Error closing MAT-file measurements.mat");
        return;
      }

      if ((fp = fopen(fileName, "r+b")) == (NULL)) {
        rtmSetErrorStatus(helikopter_M,
                          "Error reopening MAT-file measurements.mat");
        return;
      }

      if (rt_WriteMat4FileHeader(fp, 7, helikopter_DWork.ToFile1_IWORK.Count,
           "measurements")) {
        rtmSetErrorStatus(helikopter_M,
                          "Error writing header for measurements to MAT-file measurements.mat");
      }

      if (fclose(fp) == EOF) {
        rtmSetErrorStatus(helikopter_M,
                          "Error closing MAT-file measurements.mat");
        return;
      }

      helikopter_DWork.ToFile1_PWORK.FilePtr = (NULL);
    }
  }
}

/*========================================================================*
 * Start of GRT compatible call interface                                 *
 *========================================================================*/

/* Solver interface called by GRT_Main */
#ifndef USE_GENERATED_SOLVER

void rt_ODECreateIntegrationData(RTWSolverInfo *si)
{
  UNUSED_PARAMETER(si);
  return;
}                                      /* do nothing */

void rt_ODEDestroyIntegrationData(RTWSolverInfo *si)
{
  UNUSED_PARAMETER(si);
  return;
}                                      /* do nothing */

void rt_ODEUpdateContinuousStates(RTWSolverInfo *si)
{
  UNUSED_PARAMETER(si);
  return;
}                                      /* do nothing */

#endif

void MdlOutputs(int_T tid)
{
  helikopter_output(tid);
}

void MdlUpdate(int_T tid)
{
  helikopter_update(tid);
}

void MdlInitializeSizes(void)
{
  helikopter_M->Sizes.numContStates = (5);/* Number of continuous states */
  helikopter_M->Sizes.numY = (0);      /* Number of model outputs */
  helikopter_M->Sizes.numU = (0);      /* Number of model inputs */
  helikopter_M->Sizes.sysDirFeedThru = (0);/* The model is not direct feedthrough */
  helikopter_M->Sizes.numSampTimes = (2);/* Number of sample times */
  helikopter_M->Sizes.numBlocks = (42);/* Number of blocks */
  helikopter_M->Sizes.numBlockIO = (9);/* Number of block outputs */
  helikopter_M->Sizes.numBlockPrms = (146);/* Sum of parameter "widths" */
}

void MdlInitializeSampleTimes(void)
{
}

void MdlInitialize(void)
{
  /* InitializeConditions for TransferFcn: '<S2>/Vandring Lavpass' */
  helikopter_X.VandringLavpass_CSTATE = 0.0;

  /* InitializeConditions for TransferFcn: '<S2>/Vandring Deriv' */
  helikopter_X.VandringDeriv_CSTATE = 0.0;

  /* InitializeConditions for TransferFcn: '<S2>/Transfer Fcn4' */
  helikopter_X.TransferFcn4_CSTATE = 0.0;

  /* InitializeConditions for TransferFcn: '<S2>/Transfer Fcn5' */
  helikopter_X.TransferFcn5_CSTATE = 0.0;

  /* InitializeConditions for Integrator: '<S1>/Integrator' */
  helikopter_X.Integrator_CSTATE = helikopter_P.Integrator_IC;
}

void MdlStart(void)
{
  /* Start for S-Function (hil_initialize_block): '<Root>/HIL Initialize' */

  /* S-Function Block: helikopter/HIL Initialize (hil_initialize_block) */
  {
    t_int result;
    t_boolean is_switching;
    result = hil_open("q4", "0", &helikopter_DWork.HILInitialize_Card);
    if (result < 0) {
      msg_get_error_messageA(NULL, result, _rt_error_message, sizeof
        (_rt_error_message));
      rtmSetErrorStatus(helikopter_M, _rt_error_message);
      return;
    }

    is_switching = false;
    if ((helikopter_P.HILInitialize_CKPStart && !is_switching) ||
        (helikopter_P.HILInitialize_CKPEnter && is_switching)) {
      result = hil_set_clock_mode(helikopter_DWork.HILInitialize_Card, (t_clock *)
        &helikopter_P.HILInitialize_CKChannels[0], 2U, (t_clock_mode *)
        &helikopter_P.HILInitialize_CKModes[0]);
      if (result < 0) {
        msg_get_error_messageA(NULL, result, _rt_error_message, sizeof
          (_rt_error_message));
        rtmSetErrorStatus(helikopter_M, _rt_error_message);
        return;
      }
    }

    result = hil_watchdog_clear(helikopter_DWork.HILInitialize_Card);
    if (result < 0 && result != -QERR_HIL_WATCHDOG_CLEAR) {
      msg_get_error_messageA(NULL, result, _rt_error_message, sizeof
        (_rt_error_message));
      rtmSetErrorStatus(helikopter_M, _rt_error_message);
      return;
    }

    if ((helikopter_P.HILInitialize_AIPStart && !is_switching) ||
        (helikopter_P.HILInitialize_AIPEnter && is_switching)) {
      helikopter_DWork.HILInitialize_AIMinimums[0] =
        helikopter_P.HILInitialize_AILow;
      helikopter_DWork.HILInitialize_AIMinimums[1] =
        helikopter_P.HILInitialize_AILow;
      helikopter_DWork.HILInitialize_AIMinimums[2] =
        helikopter_P.HILInitialize_AILow;
      helikopter_DWork.HILInitialize_AIMinimums[3] =
        helikopter_P.HILInitialize_AILow;
      helikopter_DWork.HILInitialize_AIMaximums[0] =
        helikopter_P.HILInitialize_AIHigh;
      helikopter_DWork.HILInitialize_AIMaximums[1] =
        helikopter_P.HILInitialize_AIHigh;
      helikopter_DWork.HILInitialize_AIMaximums[2] =
        helikopter_P.HILInitialize_AIHigh;
      helikopter_DWork.HILInitialize_AIMaximums[3] =
        helikopter_P.HILInitialize_AIHigh;
      result = hil_set_analog_input_ranges(helikopter_DWork.HILInitialize_Card,
        &helikopter_P.HILInitialize_AIChannels[0], 4U,
        &helikopter_DWork.HILInitialize_AIMinimums[0],
        &helikopter_DWork.HILInitialize_AIMaximums[0]);
      if (result < 0) {
        msg_get_error_messageA(NULL, result, _rt_error_message, sizeof
          (_rt_error_message));
        rtmSetErrorStatus(helikopter_M, _rt_error_message);
        return;
      }
    }

    if ((helikopter_P.HILInitialize_AOPStart && !is_switching) ||
        (helikopter_P.HILInitialize_AOPEnter && is_switching)) {
      helikopter_DWork.HILInitialize_AOMinimums[0] =
        helikopter_P.HILInitialize_AOLow;
      helikopter_DWork.HILInitialize_AOMinimums[1] =
        helikopter_P.HILInitialize_AOLow;
      helikopter_DWork.HILInitialize_AOMinimums[2] =
        helikopter_P.HILInitialize_AOLow;
      helikopter_DWork.HILInitialize_AOMinimums[3] =
        helikopter_P.HILInitialize_AOLow;
      helikopter_DWork.HILInitialize_AOMaximums[0] =
        helikopter_P.HILInitialize_AOHigh;
      helikopter_DWork.HILInitialize_AOMaximums[1] =
        helikopter_P.HILInitialize_AOHigh;
      helikopter_DWork.HILInitialize_AOMaximums[2] =
        helikopter_P.HILInitialize_AOHigh;
      helikopter_DWork.HILInitialize_AOMaximums[3] =
        helikopter_P.HILInitialize_AOHigh;
      result = hil_set_analog_output_ranges(helikopter_DWork.HILInitialize_Card,
        &helikopter_P.HILInitialize_AOChannels[0], 4U,
        &helikopter_DWork.HILInitialize_AOMinimums[0],
        &helikopter_DWork.HILInitialize_AOMaximums[0]);
      if (result < 0) {
        msg_get_error_messageA(NULL, result, _rt_error_message, sizeof
          (_rt_error_message));
        rtmSetErrorStatus(helikopter_M, _rt_error_message);
        return;
      }
    }

    if ((helikopter_P.HILInitialize_AOStart && !is_switching) ||
        (helikopter_P.HILInitialize_AOEnter && is_switching)) {
      helikopter_DWork.HILInitialize_AOVoltages[0] =
        helikopter_P.HILInitialize_AOInitial;
      helikopter_DWork.HILInitialize_AOVoltages[1] =
        helikopter_P.HILInitialize_AOInitial;
      helikopter_DWork.HILInitialize_AOVoltages[2] =
        helikopter_P.HILInitialize_AOInitial;
      helikopter_DWork.HILInitialize_AOVoltages[3] =
        helikopter_P.HILInitialize_AOInitial;
      result = hil_write_analog(helikopter_DWork.HILInitialize_Card,
        &helikopter_P.HILInitialize_AOChannels[0], 4U,
        &helikopter_DWork.HILInitialize_AOVoltages[0]);
      if (result < 0) {
        msg_get_error_messageA(NULL, result, _rt_error_message, sizeof
          (_rt_error_message));
        rtmSetErrorStatus(helikopter_M, _rt_error_message);
        return;
      }
    }

    if (helikopter_P.HILInitialize_AOReset) {
      helikopter_DWork.HILInitialize_AOVoltages[0] =
        helikopter_P.HILInitialize_AOWatchdog;
      helikopter_DWork.HILInitialize_AOVoltages[1] =
        helikopter_P.HILInitialize_AOWatchdog;
      helikopter_DWork.HILInitialize_AOVoltages[2] =
        helikopter_P.HILInitialize_AOWatchdog;
      helikopter_DWork.HILInitialize_AOVoltages[3] =
        helikopter_P.HILInitialize_AOWatchdog;
      result = hil_watchdog_set_analog_expiration_state
        (helikopter_DWork.HILInitialize_Card,
         &helikopter_P.HILInitialize_AOChannels[0], 4U,
         &helikopter_DWork.HILInitialize_AOVoltages[0]);
      if (result < 0) {
        msg_get_error_messageA(NULL, result, _rt_error_message, sizeof
          (_rt_error_message));
        rtmSetErrorStatus(helikopter_M, _rt_error_message);
        return;
      }
    }

    if ((helikopter_P.HILInitialize_EIPStart && !is_switching) ||
        (helikopter_P.HILInitialize_EIPEnter && is_switching)) {
      helikopter_DWork.HILInitialize_QuadratureModes[0] =
        helikopter_P.HILInitialize_EIQuadrature;
      helikopter_DWork.HILInitialize_QuadratureModes[1] =
        helikopter_P.HILInitialize_EIQuadrature;
      helikopter_DWork.HILInitialize_QuadratureModes[2] =
        helikopter_P.HILInitialize_EIQuadrature;
      helikopter_DWork.HILInitialize_QuadratureModes[3] =
        helikopter_P.HILInitialize_EIQuadrature;
      result = hil_set_encoder_quadrature_mode
        (helikopter_DWork.HILInitialize_Card,
         &helikopter_P.HILInitialize_EIChannels[0], 4U,
         (t_encoder_quadrature_mode *)
         &helikopter_DWork.HILInitialize_QuadratureModes[0]);
      if (result < 0) {
        msg_get_error_messageA(NULL, result, _rt_error_message, sizeof
          (_rt_error_message));
        rtmSetErrorStatus(helikopter_M, _rt_error_message);
        return;
      }

      helikopter_DWork.HILInitialize_FilterFrequency[0] =
        helikopter_P.HILInitialize_EIFrequency;
      helikopter_DWork.HILInitialize_FilterFrequency[1] =
        helikopter_P.HILInitialize_EIFrequency;
      helikopter_DWork.HILInitialize_FilterFrequency[2] =
        helikopter_P.HILInitialize_EIFrequency;
      helikopter_DWork.HILInitialize_FilterFrequency[3] =
        helikopter_P.HILInitialize_EIFrequency;
      result = hil_set_encoder_filter_frequency
        (helikopter_DWork.HILInitialize_Card,
         &helikopter_P.HILInitialize_EIChannels[0], 4U,
         &helikopter_DWork.HILInitialize_FilterFrequency[0]);
      if (result < 0) {
        msg_get_error_messageA(NULL, result, _rt_error_message, sizeof
          (_rt_error_message));
        rtmSetErrorStatus(helikopter_M, _rt_error_message);
        return;
      }
    }

    if ((helikopter_P.HILInitialize_EIStart && !is_switching) ||
        (helikopter_P.HILInitialize_EIEnter && is_switching)) {
      helikopter_DWork.HILInitialize_InitialEICounts[0] =
        helikopter_P.HILInitialize_EIInitial;
      helikopter_DWork.HILInitialize_InitialEICounts[1] =
        helikopter_P.HILInitialize_EIInitial;
      helikopter_DWork.HILInitialize_InitialEICounts[2] =
        helikopter_P.HILInitialize_EIInitial;
      helikopter_DWork.HILInitialize_InitialEICounts[3] =
        helikopter_P.HILInitialize_EIInitial;
      result = hil_set_encoder_counts(helikopter_DWork.HILInitialize_Card,
        &helikopter_P.HILInitialize_EIChannels[0], 4U,
        &helikopter_DWork.HILInitialize_InitialEICounts[0]);
      if (result < 0) {
        msg_get_error_messageA(NULL, result, _rt_error_message, sizeof
          (_rt_error_message));
        rtmSetErrorStatus(helikopter_M, _rt_error_message);
        return;
      }
    }
  }

  /* Start for ToFile: '<Root>/To File1' */
  {
    const char *fileName = "measurements.mat";
    FILE *fp = (NULL);
    if ((fp = fopen(fileName, "wb")) == (NULL)) {
      rtmSetErrorStatus(helikopter_M,
                        "Error creating .mat file measurements.mat");
      return;
    }

    if (rt_WriteMat4FileHeader(fp,7,0,"measurements")) {
      rtmSetErrorStatus(helikopter_M,
                        "Error writing mat file header to file measurements.mat");
      return;
    }

    helikopter_DWork.ToFile1_IWORK.Count = 0;
    helikopter_DWork.ToFile1_IWORK.Decimation = -1;
    helikopter_DWork.ToFile1_PWORK.FilePtr = fp;
  }

  /* Start for FromWorkspace: '<Root>/From Workspace' */
  {
    static real_T pTimeValues[] = { 0.0, 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75,
      2.0, 2.25, 2.5, 2.75, 3.0, 3.25, 3.5, 3.75, 4.0, 4.25, 4.5, 4.75, 5.0,
      5.25, 5.5, 5.75, 6.0, 6.25, 6.5, 6.75, 7.0, 7.25, 7.5, 7.75, 8.0, 8.25,
      8.5, 8.75, 9.0, 9.25, 9.5, 9.75, 10.0, 10.25, 10.5, 10.75, 11.0, 11.25,
      11.5, 11.75, 12.0, 12.25, 12.5, 12.75, 13.0, 13.25, 13.5, 13.75, 14.0,
      14.25, 14.5, 14.75, 15.0, 15.25, 15.5, 15.75, 16.0, 16.25, 16.5, 16.75,
      17.0, 17.25, 17.5, 17.75, 18.0, 18.25, 18.5, 18.75, 19.0, 19.25, 19.5,
      19.75, 20.0, 20.25, 20.5, 20.75, 21.0, 21.25, 21.5, 21.75, 22.0, 22.25,
      22.5, 22.75, 23.0, 23.25, 23.5, 23.75, 24.0, 24.25, 24.5, 24.75 } ;

    static real_T pDataValues[] = { 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 0.5,
      0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5,
      0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5,
      0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5,
      0.5 } ;

    helikopter_DWork.FromWorkspace_PWORK.TimePtr = (void *) pTimeValues;
    helikopter_DWork.FromWorkspace_PWORK.DataPtr = (void *) pDataValues;
    helikopter_DWork.FromWorkspace_IWORK.PrevIndex = 0;
  }

  MdlInitialize();
}

void MdlTerminate(void)
{
  helikopter_terminate();
}

RT_MODEL_helikopter *helikopter(void)
{
  helikopter_initialize(1);
  return helikopter_M;
}

/*========================================================================*
 * End of GRT compatible call interface                                   *
 *========================================================================*/
