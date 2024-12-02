Type TFilter
	Const   HIGH:Int=1, LOW:Int=0, BAND:Int=2
	Field   Typ:Int, Limit:Int, HERTZ:Int
	Field   B_0:Double, B_1:Double, B_2:Double, A_1:Double, A_2:Double
	Field 	OverLastResult:Double, LastResult:Double
	Field 	Last:Double, OverLast:Double

'**********************************************************************************
' PUBLIC

	' LOW PASS FILTER:
	Function CreateLowPass:TFilter( LimitFrequency:Int, SampleRate:Int)
		Local loc:TFilter = New TFilter
		loc.Typ   = LOW
		loc.Limit = LimitFrequency
		loc.HERTZ = SampleRate
		loc.DefineLowPass
		Return loc
	End Function


	' HIGH PASS FILTER:
	Function CreateHighPass:TFilter( LimitFrequency:Int, SampleRate:Int)
		Local loc:TFilter = New TFilter
		loc.Typ   = LOW
		loc.Limit = LimitFrequency
		loc.HERTZ = SampleRate
		loc.DefineHighPass
		Return loc
	End Function


	' BAND PASS FILTER:
	Function CreateBandPass:TFilter( LimitFrequency:Int, SampleRate:Int)
		Local loc:TFilter = New TFilter
		loc.Typ   = BAND
		loc.Limit = LimitFrequency
		loc.HERTZ = SampleRate
		loc.DefineBandPass
		Return loc
	End Function


	' NOTCH FILTER:
	Function CreateNotch:TFilter( LimitFrequency:Int, SampleRate:Int)
		Local loc:TFilter = New TFilter
		loc.Typ   = BAND
		loc.Limit = LimitFrequency
		loc.HERTZ = SampleRate
		loc.DefineNotch
		Return loc
	End Function


	' PROCESS FOR ALL FILTERS:
	Method Process:Double(Sample:Double)
		Local Result:Double = (Sample*B_0) + (Last*B_1) + (OverLast*B_2) -(LastResult*A_1) - (OverLastResult*A_2)		
		OverLast       = Last
		Last           = Sample
		OverLastResult = LastResult
		LastResult     = Result
		Return Result
	End Method

	
'**********************************************************************************
' PPRIVATE
	
	Method DefineLowPass()
		Local COSINUS:Double, ALPHA:Double, INV_ALPHA:Double
		Local QUALITY:Double = 0.7
		Local w:Double = 360.0*Limit/HERTZ
		COSINUS  = Cos(w)
		ALPHA    = Sin(w)/2/QUALITY
		INV_ALPHA = 1/(1+ALPHA)
		
		B_0 = Float ((1-COSINUS)*0.5 * INV_ALPHA)
		B_1 = Float ((1-COSINUS)     * INV_ALPHA)
		B_2 = B_0
		A_1 = Float((-2*COSINUS)     * INV_ALPHA)
		A_2 = Float ((1-ALPHA)       * INV_ALPHA)
	End Method



	Method DefineHighPass()
		Local COSINUS:Double, ALPHA:Double, INV_ALPHA:Double
		Local QUALITY:Double = 0.7
		Local w:Double = 360.0*Limit/HERTZ
		COSINUS  = Cos(w)
		ALPHA    = Sin(w)/2/QUALITY
		INV_ALPHA = 1/(1+ALPHA)
		
		B_0 = Float ((1+COSINUS)*0.5 * INV_ALPHA)
		B_1 = Float ((-1-COSINUS)     * INV_ALPHA)
		B_2 = B_0
		A_1 = Float((-2*COSINUS)     * INV_ALPHA)
		A_2 = Float ((1-ALPHA)       * INV_ALPHA)
	End Method



	Method DefineBandPass()
		Local COSINUS:Double, ALPHA:Double, INV_ALPHA:Double
		Local QUALITY:Double = 0.7
		Local w:Double = 360.0*Limit/HERTZ
		COSINUS  = Cos(w)
		ALPHA    = Sin(w)/2/QUALITY
		INV_ALPHA = 1/(1+ALPHA)
		
		B_0 = Float (ALPHA * INV_ALPHA)
		B_1 = 0
		B_2 = -B_0
		A_1 = Float((-2*COSINUS)     * INV_ALPHA)
		A_2 = Float ((1-ALPHA)       * INV_ALPHA)
	End Method
	


	Method DefineNotch()
		Local COSINUS:Double, ALPHA:Double, INV_ALPHA:Double
		Local QUALITY:Double = 0.7
		Local w:Double = 360.0*Limit/HERTZ
		COSINUS  = Cos(w)
		ALPHA    = Sin(w)/2/QUALITY
		INV_ALPHA = 1/(1+ALPHA)
		
		B_0 = INV_ALPHA
		B_1 = Float((-2*COSINUS)     * INV_ALPHA)
		B_2 = B_0
		A_1 = B_1
		A_2 = Float ((1-ALPHA)       * INV_ALPHA)
	End Method

			
'**********************************************************************************
' EXPERIMENTAL

	Method OptimalProcess:Double(Sample:Double)
		' 20% faster for LowPass and HighPass
		Local Result:Double = ((Sample+OverLast)*B_0) + (Last*B_1)  -(LastResult*A_1) - (OverLastResult*A_2)		
		OverLast       = Last
		Last           = Sample
		OverLastResult = LastResult
		LastResult     = Result
		Return Result
	End Method


	Method OptimalBandProcess:Double(Sample:Double)
		' 20% faster for BandPass
		Local Result:Double = ((Sample-OverLast)*B_0) - (LastResult*A_1) - (OverLastResult*A_2)		
		OverLast       = Last
		Last           = Sample
		OverLastResult = LastResult
		LastResult     = Result
		Return Result
	End Method


	Method OptimalNotchProcess:Double(Sample:Double)
		' 20% faster for Notch
		Local Result:Double = (Sample+OverLast)*B_0 + (Last-LastResult)*B_1  - (OverLastResult*A_2)		
		OverLast       = Last
		Last           = Sample
		OverLastResult = LastResult
		LastResult     = Result
		Return Result
	End Method

	Method ResetAllGlobals()
		B_0=0
		B_1=0
		B_2=0
		A_1=0
		A_2=0
		OverLastResult=0
		LastResult=0
		Last=0
		OverLast=0
	End Method

End Type
