Field Properties
================

.. note:: Any properties not explicitly listed here are either implicitly
    supported, or are not relevant to the regblock exporter and are ignored.

Software Access Properties
--------------------------

onread/onwrite
^^^^^^^^^^^^^^
|OK|

rclr/rset
^^^^^^^^^
See ``onread``

singlepulse
^^^^^^^^^^^
|OK|

If set, field will get cleared back to zero after being written.

.. wavedrom::

    {"signal": [
        {"name": "clk",             "wave": "p....."},
      	{"name": "<swmod>",         "wave": "0.10.."},
        {"name": "hwif_out..value", "wave": "0..10."}
    ]}

sw
^^^
|OK|

swacc
^^^^^
|OK|

If true, infers an output signal ``hwif_out..swacc`` that is asserted on the
same clock cycle that the field is being sampled during a software read
operation.

.. wavedrom::

    {"signal": [
        {"name": "clk",             "wave": "p...."},
        {"name": "hwif_in..next",   "wave": "x.=x.", "data": ["D"]},
        {"name": "hwif_out..swacc", "wave": "0.10."}
    ]}


swmod
^^^^^
|OK|

If true, infers an output signal ``hwif_out..swmod`` that is asserted as the
field is being modified by software.

.. wavedrom::

    {"signal": [
        {"name": "clk",             "wave": "p....."},
        {"name": "hwif_out..value", "wave": "=..=..", "data": ["old", "new"]},
        {"name": "hwif_out..swmod", "wave": "0.10.."}
    ]}


swwe/swwel
^^^^^^^^^^

Provides a mechanism that allows hardware to override whether the field is
writable by software.

boolean
    |OK|

    If True, infers an input signal ``hwif_in..swwe`` or ``hwif_in..swwel``.

reference
    |OK|


woclr/woset
^^^^^^^^^^^
See ``onwrite``


--------------------------------------------------------------------------------

Hardware Access Properties
--------------------------

anded/ored/xored
^^^^^^^^^^^^^^^^
|OK|

If true, infers the existence of output signal: ``hwif_out..anded``,
``hwif_out..ored``, ``hwif_out..xored``


hw
^^^
|OK|

Controls hardware access to the field.

If readable, enables output signal ``hwif_out..value``. If writable, enables
input ``hwif_in..next``.

Hardware-writable fields can optionally define the ``next`` property which replaces
the inferred ``hwif_in..next`` input with an alternate reference.


hwclr/hwset
^^^^^^^^^^^

If both ``hwclr`` and ``hwset`` properties are used, and both are asserted at
the same clock cycle, then ``hwset`` will take precedence.

boolean
    |OK|

    If true, infers the existence of input signal: ``hwif_in..hwclr``, ``hwif_in..hwset``

reference
    |OK|

hwenable/hwmask
^^^^^^^^^^^^^^^
|OK|

Reference to a component that provides bit-level control of hardware writeability.


we/wel
^^^^^^
Write-enable control from hardware interface.

If true, infers the existence of input signal: ``hwif_in..we``, ``hwif_in..wel``

.. wavedrom::

    {"signal": [
        {"name": "clk",             "wave": "p...."},
        {"name": "hwif_in..next",   "wave": "x.=x.", "data": ["D"]},
        {"name": "hwif_in..we",     "wave": "0.10."},
        {"name": "hwif_in..wel",    "wave": "1.01."},
        {"name": "<field value>",   "wave": "x..=.", "data": ["D"]}
    ]}

boolean
    |OK|

    If true, infers the existence of input signal ``hwif_in..we`` or ``hwif_in..wel``

reference
    |OK|


--------------------------------------------------------------------------------

Counter Properties
------------------

counter
^^^^^^^
|OK|

If true, marks this field as a counter. The counter direction is inferred based
based on which properties are assigned. By default, an up-counter is implemented.
If any of the properties associated with an up-counter are used, then up-counting
capabilities will be implemented. The same is true for down-counters and up/down
counters.

Unless alternate control signals are specified, the existence of input signals
``hwif_in..incr`` and ``hwif_in..decr`` will be inferred depending on the type
of counter described.


incr
^^^^
|OK|

Assign a reference to an alternate control signal to increment the counter.
If assigned, the inferred ``hwif_in..incr`` input will not be generated.

incrsaturate/saturate
^^^^^^^^^^^^^^^^^^^^^
If assigned, indicates that the counter will saturate instead of wrapping.
If an alternate saturation point is specified, the counter value will be
adjusted so that it does not exceed that limit, even after non-increment actions.

boolean
    |OK|

    If true, saturation point is at the counter's maximum count value. (2^width - 1)

integer
    |OK|

    Specify a static saturation value.

reference
    |OK|

    Specify a dynamic saturation value.


incrthreshold/threshold
^^^^^^^^^^^^^^^^^^^^^^^

If assigned, infers a ``hwif_out..incrthreshold`` output signal. This signal is
asserted if the counter value is greater or equal to the threshold.

.. wavedrom::

    {
        "signal": [
            {"name": "clk",                     "wave": "p......"},
            {"name": "hwif_in..incr",           "wave": "01...0."},
            {"name": "<counter>",               "wave": "=.=3==..", "data": [4,5,6,7,8,9]},
            {"name": "hwif_out..incrthreshold", "wave": "0..1...."}
        ],
        "foot": {
            "text": "Example where incrthreshold = 6"
        }
    }


boolean
    |OK|

    If true, threshold is the counter's maximum count value. (2^width - 1)

integer
    |OK|

    Specify a static threshold value.

reference
    |OK|

    Specify a dynamic threshold value.


incrvalue
^^^^^^^^^
Override the counter's increment step size.

integer
    |OK|

reference
    |OK|

incrwidth
^^^^^^^^^
|OK|

If assigned, infers an input signal ``hwif_in..incrvalue``. The value of this
property defines the signal's width.


overflow
^^^^^^^^
|OK|

If true, infers an output signal ``hwif_out..overflow`` that is asserted when
the counter is about to wrap.

.. wavedrom::

    {
        "signal": [
            {"name": "clk",                "wave": "p......."},
            {"name": "hwif_in..incr",      "wave": "0101010."},
            {"name": "<counter>",          "wave": "=.=.=.=.", "data": [14,15,0,1]},
            {"name": "hwif_out..overflow", "wave": "0..10..."}
        ],
        "foot": {
            "text": "A 4-bit counter overflowing"
        }
    }


decr
^^^^
|OK|

Assign a reference to an alternate control signal to decrement the counter.
If assigned, the inferred ``hwif_in..decr`` input will not be generated.


decrsaturate
^^^^^^^^^^^^
If assigned, indicates that the counter will saturate instead of wrapping.
If an alternate saturation point is specified, the counter value will be
adjusted so that it does not exceed that limit, even after non-decrement actions.

boolean
    |OK|

    If true, saturation point is when the counter reaches 0.

integer
    |OK|

    Specify a static saturation value.

reference
    |OK|

    Specify a dynamic saturation value.


decrthreshold
^^^^^^^^^^^^^
If assigned, infers a ``hwif_out..decrthreshold`` output signal. This signal is
asserted if the counter value is less than or equal to the threshold.

.. wavedrom::

    {
        "signal": [
            {"name": "clk",                     "wave": "p......"},
            {"name": "hwif_in..decr",           "wave": "01...0."},
            {"name": "<counter>",               "wave": "=.=3==.", "data": [9,8,7,6,5,4]},
            {"name": "hwif_out..decrthreshold", "wave": "0..1..."}
        ],
        "foot": {
            "text": "Example where incrthreshold = 7"
        }
    }


boolean
    |OK|

    If true, threshold is 0.

integer
    |OK|

    Specify a static threshold value.

reference
    |OK|

    Specify a dynamic threshold value.


decrvalue
^^^^^^^^^
Override the counter's decrement step size.

integer
    |OK|

reference
    |OK|

decrwidth
^^^^^^^^^
|OK|

If assigned, infers an input signal ``hwif_in..decrvalue``. The value of this
property defines the signal's width.

underflow
^^^^^^^^^
|OK|

If true, infers an output signal ``hwif_out..underflow`` that is asserted when
the counter is about to wrap.

.. wavedrom::

    {
        "signal": [
            {"name": "clk",                 "wave": "p......."},
            {"name": "hwif_in..decr",       "wave": "0101010."},
            {"name": "<counter>",           "wave": "=.=.=.=.", "data": [1,0,15,14]},
            {"name": "hwif_out..underflow", "wave": "0..10..."}
        ],
        "foot": {
            "text": "A 4-bit counter underflowing"
        }
    }

--------------------------------------------------------------------------------

Interrupt Properties
--------------------

intr
^^^^

If set, this field becomes an interrupt field.
The enclosing register infers an output signal ``hwif_out..intr`` which denotes
that an interrupt is active. This is an or-reduction of all interrupt fields
after applying the appropriate ``enable`` or ``mask`` to the field value.

level (default)
    |OK|

    Interrupt is level-sensitive. If a bit on the field's ``hwif_in..next`` input
    is '1', it will trigger an interrupt event.

posedge
    |OK|

    If a bit on the field's ``hwif_in..next`` input transitions from '0' to '1',
    it will trigger an interrupt event. This transition shall still be synchronous
    to the register block's clock.

negedge
    |OK|

    If a bit on the field's ``hwif_in..next`` input transitions from '1' to '0',
    it will trigger an interrupt event. This transition shall still be synchronous
    to the register block's clock.

bothedge
    |OK|

    If a bit on the field's ``hwif_in..next`` input transitions from '0' to '1' or '1' to '0',
    it will trigger an interrupt event. This transition shall still be synchronous
    to the register block's clock.

nonsticky
    |OK|


enable
^^^^^^
|OK|

Reference to a field or signal that, if set to 1, define which bits in the field
are used to assert an interrupt.


mask
^^^^
|OK|

Reference to a field or signal that, if set to 1, define which bits in the field
are *not* used to assert an interrupt.


haltenable
^^^^^^^^^^
|OK|

Reference to a field or signal that, if set to 1, define which bits in the field
are used to assert the halt output.

If this property is set, the enclosing register will infer a ``hwif_out..halt`` output.


haltmask
^^^^^^^^
|OK|

Reference to a field or signal that, if set to 1, define which bits in the field
are *not* used to assert the halt output.

If this property is set, the enclosing register will infer a ``hwif_out..halt`` output.


stickybit
^^^^^^^^^
|OK|

When an interrupt trigger occurs, a stickybit field will set the corresponding
bit to '1' and hold it until it is cleared by a software access.

The interrupt trigger depends on the interrupt type. By default, interrupts are
level-sensitive, but the interrupt modifiers allow for edge-sensitive triggers as
well.

The waveform below demonstrates a level-sensitive interrupt:

.. wavedrom::

    {
        "signal": [
            {"name": "clk",                 "wave": "p....."},
            {"name": "hwif_in..next",       "wave": "010..."},
            {"name": "<field value>",       "wave": "0.1..."}
        ]
    }


sticky
^^^^^^
|OK|

Unlike ``stickybit`` fields, a sticky field will latch an entire value. The
value is latched as soon as ``hwif_in..next`` is nonzero, and is held until the
field contents are cleared back to 0 by a software access.

.. wavedrom::

    {
        "signal": [
            {"name": "clk",                 "wave": "p....."},
            {"name": "hwif_in..next",       "wave": "23.22.", "data": [0,10,20,30]},
            {"name": "<field value>",       "wave": "2.3...", "data": [0, 10]}
        ]
    }


--------------------------------------------------------------------------------

Misc
----

encode
^^^^^^
|NO|

next
^^^^
|OK|

If assigned, replaces the inferred ``hwif_in..next`` input with an explicit reference.


paritycheck
^^^^^^^^^^^
|NO|

precedence
^^^^^^^^^^
|OK|

reset
^^^^^
integer
    |OK|

reference
    |OK|

resetsignal
^^^^^^^^^^^
|OK|
