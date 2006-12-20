\d .kalman

/	VARIABLES
/	---------


pv : 1f
mv : 1f
xh : ()


/	FUNCTIONS
/	---------


filter : {
        x : `float$ x;
        mv :: var x;
        xh :: enlist ( first x; mv );
        if[ 1 < count x;
            { xh ,: enlist correct[predict last xh; x] } each 1 _ x;
        ];
        xh
    }

predict : { ( first x; pv + last x ) }

correct : {
        k : lxh % mv + lxh:last x;
        ( fxh + k * y - fxh:first x; ( 1 - k ) * lxh )
    }


\d .
