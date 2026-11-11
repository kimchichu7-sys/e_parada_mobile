<?php
$options = [PDO::ATTR_PERSISTENT => true];

$t0 = microtime(true);
$pdo1 = new PDO('pgsql:host=aws-0-ap-northeast-2.pooler.supabase.com;port=5432;dbname=postgres;sslmode=require', 'postgres.whojxuujrjnuyscprfyi', 'jungchichu11', $options);
$t1 = microtime(true);
echo "First connection: " . round(($t1-$t0)*1000) . " ms\n";

$t2 = microtime(true);
$pdo2 = new PDO('pgsql:host=aws-0-ap-northeast-2.pooler.supabase.com;port=5432;dbname=postgres;sslmode=require', 'postgres.whojxuujrjnuyscprfyi', 'jungchichu11', $options);
$t3 = microtime(true);
echo "Second (persistent) connection: " . round(($t3-$t2)*1000) . " ms\n";
