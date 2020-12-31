<?php
header("Access-Control-Allow-Origin: *"); 
$con = mysqli_connect("localhost","zmr_InjoyAppIosUser", "Juan123", "zmr_InjoyAppIos") or die ("could not connect database");
if (mysqli_connect_errno()){ echo "Failed to connect to MySQL: " . mysqli_connect_error(); }

/* 
1 = HAY UNA SESSION ACTIVA Y NO HAY FACTRURA PENTIENDE
2 = HAY UNA SESSION ACTIVA Y NO SE A ORDENADO NADA. PUEDE CERRAR LA APP Y AL ENTRAR LE PREGUNTA DE NUEVO SI CONTINUA
3 = HAY UNA SESSION ACTIVA Y HAY UNA FACTURA PENDIENTE POR PAGAR
*/

if (!isset($_GET['ID'])) $_GET['ID'] = 1;
if (!isset($_GET['OP'])) $_GET['OP'] = 1;

if (isset($_GET['OP'])){
	$sql = "UPDATE app_session_user SET sessionStatus=".$_GET['OP']." WHERE sessionID='".$_GET['ID']."'" ;
}

if ($result = mysqli_query($con, $sql)){}
mysqli_close($con);
?>