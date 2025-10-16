<?php

declare(strict_types=1);

namespace MononokeApp;

require __DIR__ . '/../vendor/autoload.php';

use GuzzleHttp\Psr7\Response as Psr7Response;
use Kekke\Mononoke\Attributes\AwsSnsSqs;
use Kekke\Mononoke\Attributes\Http;
use Kekke\Mononoke\Enums\HttpMethod;
use Kekke\Mononoke\Helpers\Logger;
use Kekke\Mononoke\Service as MononokeService;
use Kekke\Mononoke\Transport\AwsSns;
use Swoole\Http\Request;

class Service extends MononokeService
{
    #[Http(method: HttpMethod::GET, path: '/health')]
    public function status(): string
    {
        return "OK";
    }

    #[Http('GET', '/json')]
    public function json(): array
    {
        return ['test' => 'json', 'number' => 1234, 'array' => [1, 2, 3, 4]];
    }

    #[Http('GET', '/custom')]
    public function custom(): Psr7Response
    {
        return new Psr7Response(201, ['Authorization' => 'Bearer XXX'], "Body");
    }

    #[Http('POST', '/post')]
    public function post(Request $request): Psr7Response
    {
        var_dump($request->header);
        var_dump($request->getContent());
        return new Psr7Response(201, ['Authorization' => 'Bearer XXX'], "Body");
    }

    /**
     * Receive a message and forward to another topic using Mononoke\Transport\AwsSns
     */
    #[AwsSnsSqs('mononoke-topic', 'mononoke-queue')]
    public function incoming($message): void
    {
        Logger::info("Received message!", ["Message" => $message]);
        AwsSns::publish(topic: 'another-topic', data: ['msg' => 'I have received a message and I\'m passing it along']);
    }
}