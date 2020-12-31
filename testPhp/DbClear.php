<?php
header("Access-Control-Allow-Origin: *"); 
$con = mysqli_connect("localhost","injoycom_root", "cotoplas2017", "injoycom_wp") or die ("could not connect database");
if (mysqli_connect_errno()){ echo "Failed to connect to MySQL: " . mysqli_connect_error(); }

if (!isset($_GET['ID'])) $_GET['ID'] = 1;
if (!isset($_GET['OP'])) $_GET['OP'] = 1;

if     ($_GET['OP'] == 1){
	$sql = "DELETE FROM app_order WHERE sessionID='".$_GET['ID']."' AND payerName=0" ;
}elseif($_GET['OP'] == 2){
	$sql = "DELETE FROM app_order_round WHERE sessionID='".$_GET['ID']."'";
}

if ($result = mysqli_query($con, $sql)){}
mysqli_close($con);
?>