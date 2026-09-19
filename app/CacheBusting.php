<?php

namespace App;

use Sculpin\Core\Event\SourceSetEvent;
use Sculpin\Core\Permalink\Permalink;
use Sculpin\Core\Sculpin;
use Symfony\Component\EventDispatcher\EventSubscriberInterface;
use Twig\Extension\AbstractExtension;
use Twig\TwigFunction;

/**
 * Serves each stylesheet and script from a URL containing a hash of its contents.
 *
 * Any change to their contents results in a new URL that is not cached yet, so
 * they can be cached forever (see `Cache-Control` in `www/.htaccess`).
 *
 * This applies to every stylesheet and script, so templates have to reference
 * them through `asset()` to get the URL they are actually published under.
 */
class CacheBusting extends AbstractExtension implements EventSubscriberInterface
{
    public function __construct(private readonly string $sourceDir)
    {
    }

    public static function getSubscribedEvents(): array
    {
        return [Sculpin::EVENT_AFTER_GENERATE => 'onAfterGenerate'];
    }

    public function getFunctions(): array
    {
        return [new TwigFunction('asset', [$this, 'asset'])];
    }

    public function asset(string $path): string
    {
        return $this->versioned($path) ?? throw new \InvalidArgumentException('Unable to version ' . $path);
    }

    public function onAfterGenerate(SourceSetEvent $event): void
    {
        foreach ($event->allSources() as $source) {
            $versioned = $this->versioned($source->relativePathname());
            if ($versioned !== null) {
                $source->setPermalink(new Permalink($versioned, '/' . $versioned));
            }
        }
    }

    /**
     * `src/tailwind.min.css` => `src/tailwind.1234567.css`, `null` for anything else
     *
     * Any `.min` or `.v2` in the source name is dropped: the hash already says
     * this is a generated file, so repeating it in the public URL adds nothing.
     */
    private function versioned(string $path): ?string
    {
        if (!preg_match('/\.(css|js)$/', $path)) {
            return null;
        }

        $hash = @sha1_file($this->sourceDir . '/' . $path);
        if ($hash === false) {
            throw new \RuntimeException('Unable to hash ' . $path);
        }

        return preg_replace(
            '/(?:\.(?:min|v\d+))*\.([^.]+)$/',
            '.' . substr($hash, 0, 7) . '.$1',
            $path
        );
    }
}
