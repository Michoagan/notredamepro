<?php
$req = Request::create('/api/professeurs/espace/emploi-du-temps', 'GET');
$req->headers->set('Accept', 'application/json');
$res = app()->handle($req);
echo "STATUS_CODE: " . $res->getStatusCode() . "\n";
echo "CONTENT: " . $res->getContent() . "\n";
