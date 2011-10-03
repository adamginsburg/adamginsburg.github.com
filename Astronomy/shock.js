document.write("Hello World");

function chisquare(measured,modeled,variance)
{
	return var chi=Math.pow((measured-modeled),2)/variance;
}

function handler(inputdata)
{
	chi=chisquare(inputdata.FeII8169.value,1,.5);
	document.write(chi);
	document.write(chisqare(inputdata.FeII8169.value,1,.5));
	alert(chi);
	return false;
}

function alertfunc()
{
	alert("FUNC!");
}