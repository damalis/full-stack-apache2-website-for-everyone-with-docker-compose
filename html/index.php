<?php

$link = mysqli_connect( 'database', 'DB_USER', 'DB_PASSWORD', 'DB_NAME' );

//if connection is not successful you will see text error
if ( !$link ) {
       die( '<center>Could not connect: ' . mysql_error() . '</center>' );
}

//if connection is successfully you will see message below
echo '<center>Connected successfully</center>';
echo "<center>Host information: " . mysqli_get_host_info( $link ) . PHP_EOL . "</center>";
 
mysqli_close( $link );

phpinfo();

?>
