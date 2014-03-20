<?php

function sendNotification( $apiKey, $registrationIdsArray, $messageData )
{   
    $headers = array("Content-Type:" . "application/json", "Authorization:" . "key=" . $apiKey);
    $data = array("registration_ids" => $registrationIdsArray, "data" => $messageData);
 
    $ch = curl_init();
 
    
    curl_setopt( $ch, CURLOPT_URL, "https://android.googleapis.com/gcm/send" );
    curl_setopt( $ch, CURLOPT_POST, true );
    curl_setopt( $ch, CURLOPT_HTTPHEADER, $headers ); 
    //curl_setopt( $ch, CURLOPT_SSL_VERIFYHOST, 0 );
    //curl_setopt( $ch, CURLOPT_SSL_VERIFYPEER, 0 );
    curl_setopt( $ch, CURLOPT_RETURNTRANSFER, true );
    curl_setopt( $ch, CURLOPT_POSTFIELDS, json_encode($data) );
 
    $response = curl_exec($ch);
    curl_close($ch);
 
    return $response;
}

// Message to send
$message      = "the test message";
$tickerText   = "ticker text message";
$contentTitle = "content title";
$contentText  = "content body";
 
$registrationId = "APA91bGVlTvb8laQVOpadTScBwcj_gv9F8SRW25iCYdQp_dihmDwWpBEVOMR1zdDen_432-WFBN_w7mx36mRtjQ-97LpmBQc3YeyuWCndPHbRxbRSc5ech89ET-7EgTT8xVY81Mgzuag1T81pPXcn0_ROgiGhd8JSN-cSOUt6q9UJzpWgxOEO5U";
$apiKey = "AIzaSyCgVafUgD5bb0ZqqTOsz1uvoEzye0vOwEk";
 
$response = sendNotification( 
                $apiKey, 
                array($registrationId), 
                array("tickerText" => $tickerText, "contentTitle" => $contentTitle, "contentText" => $contentText, "sound" => "default", "lolfh" => "sdgdfg") );
 
echo $response;