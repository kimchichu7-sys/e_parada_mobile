<?php
require __DIR__ . '/../e_parada_web/vendor/autoload.php';
$app = require __DIR__ . '/../e_parada_web/bootstrap/app.php';

$req = Illuminate\Http\Request::create('/up', 'GET');

// Warmup
ob_start();
$app->handleRequest($req);
ob_end_clean();

$times = [];
for ($i = 0; $i < 50; $i++) {
    $t0 = microtime(true);
    ob_start();
    $res = $app->handleRequest($req);
    ob_end_clean();
    $times[] = (microtime(true) - $t0) * 1000;
}
sort($times);
$avg = array_sum($times) / count($times);
$p95 = $times[(int)(count($times) * 0.95)];

echo json_encode([
    'avg_ms' => round($avg, 2),
    'p95_ms' => round($p95, 2),
    'min_ms' => round($times[0], 2),
    'max_ms' => round($times[count($times)-1], 2),
    'sample_count' => count($times)
]);
