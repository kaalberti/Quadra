# Servo-qualified operating mass — MEC-169

The user permits additional weight if the servos can handle it. Complete2kg
mass is a preferred target;qualified maximum remains TBD. Battery,electronics,
wiring and all onboard hardware still count. Favor cheap,simple,conservative
prototypes rather than weight optimization solely to meet2kg.

Only a minimum comparison is needed before the first load trial. Reuse the
existing three-support-leg J1 screen at+30degrees and120mm stance:87.7128mm
lateral lever plus0.12Nm rough moving-part allowance. This pose/allowance is
provisional and omits dynamic/uneven loading. It is not a released loaded range.

| Complete mass study point | Foot force per support leg | J1 torque screen |
| --- | ---: | ---: |
|2.0kg reference |6.54N |0.694Nm |
|2.2kg illustrative heavier prototype |7.194N |0.751Nm |

Formula:mass x9.81 /3 x0.0877128 +0.12. Keep the moving-part allowance fixed
for this brief comparison;actual printed/servo mass distribution is unmeasured.
[TowerPro](https://towerpro.com.tw/product/mg996r/) publishes9.4kgf-cm at4.8V
(0.922Nm stall) and11kgf-cm at6V. The shared proposed5.2V rail does not justify
using the6V rating. The2.2kg/+30degree example is about81% of the lower stall
reference,which gives no reliable continuous torque or thermal margin claim.
No stall-derived maximum robot mass is calculated or approved.

Keep initial supported load tests near the measured/calibrated intended stance,
start below full load and observe joint motion,current,voltage droop,holding,
horn slip and heating. Increase only after successful lower-load behavior.
A simple representative three-leg foot load is actual intended mass x9.81 /3;
for2.2kg that is about7.2N. Do not deliberately stall a servo. Whole-robot
standing and slow-motion duty must later confirm the intended operating mass.

If MG996R cannot handle the actual robot,first reduce useful abduction/stance
leverage or operating demand where practical,then reconsider mass/servos with
quantity cost. Servo choice,bench5.2V rail and current capacity assumptions
remain provisional;MG90S remains unsuitable for the existing loaded leg.
No physical test,power/travel widening,servo upgrade or battery selection occurs
here. The current mass estimate remains2.178kg and physical calibration is unset.
