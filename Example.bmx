SuperStrict
Include "mimaFilter.bmx"
Global Sample:TAudioSample =LoadAudioSample("test.ogg")
Print "HERTZ = " + Sample.Hertz
Print "Length of audio = " + sample.length
Global Pointer:Short Ptr = Sample.Samples	


Local LowPass:TFilter  = TFilter.CreateLowPass  (200,Sample.Hertz)
Local HighPass:TFilter = TFilter.CreateHighPass (3000,Sample.Hertz)
Local BandPass:TFilter  = TFilter.CreateBandPass  (1500,Sample.Hertz)
Local Notch:TFilter  = TFilter.CreateNotch  (1500,Sample.Hertz)


For Local i:Int=0 Until sample.length
	Local value:Double = ShortToInt(Pointer[i])
	value = Notch.Process(value)	
	Pointer[i] = Int(Value)
Next

Global Sound:TSound=LoadSound(Sample)
PlaySound Sound
WaitKey()

Function ShortToInt:Int( s:Int )
    Return (s Shl 16) Sar 16
End Function

