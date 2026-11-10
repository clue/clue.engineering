<?php

namespace App;

use Phiki\Phiki;
use Sculpin\Bundle\MarkdownBundle\PhpMarkdownExtraParser;

/**
 * Highlights fenced code blocks such as ```php at build time.
 *
 * Tokens are colored with inline styles, so pages need neither JavaScript nor
 * a stylesheet. Tokens in the theme's default color are left as plain text, so
 * they keep the color of the surrounding page.
 *
 * Code blocks in any other language (such as console sessions) or without a
 * language are only escaped, exactly like the default Markdown parser does.
 */
class MarkdownParser extends PhpMarkdownExtraParser
{
    private const LANGUAGES = ['php', 'json'];

    private const THEME = 'github-light-high-contrast';

    public function __construct()
    {
        parent::__construct();

        $phiki = new Phiki();
        $default = $phiki->environment()->themes->get(self::THEME)->base()->foreground;
        $this->code_block_content_func = function (string $code, string $language) use ($phiki, $default): string {
            $language = strtolower($language);
            if (!in_array($language, self::LANGUAGES, true)) {
                return htmlspecialchars($code, ENT_NOQUOTES);
            }

            // fenced code always ends with a newline, which highlighting adds to every line anyway
            $html = '';
            foreach ($phiki->codeToHighlightedTokens(substr($code, 0, -1), $language, self::THEME) as $line) {
                foreach ($line as $token) {
                    $color = $token->settings['default']->foreground ?? $default;
                    $text = htmlspecialchars($token->token->text, ENT_NOQUOTES);
                    $html .= $color === $default ? $text : '<span style="color: ' . $color . '">' . $text . '</span>';
                }
            }

            return $html;
        };
    }
}
