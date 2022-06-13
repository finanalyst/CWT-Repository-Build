![github-tests-passing-badge](https://github.com/finanalyst/Cro-WebApp-Template-Repository-Hash/actions/workflows/test.yaml/badge.svg)
# Cro::WebApp::Template::Repository::Hash
>Using Cro templates in a Hash


## Table of Contents
[Introduction](#introduction)  
[Usage](#usage)  
[Dependencies](#dependencies)  
[Differences from CWT documentation](#differences-from-cwt-documentation)  
[sub templates-from-hash( %hash-of-templates )](#sub-templates-from-hash-hash-of-templates-)  
[sub render-template( $template, $topic, :%parts, :build($)! )](#sub-render-template-template-topic-parts-build-)  
[sub modify-template-hash( %templates )](#sub-modify-template-hash-templates-)  
[sub wait-for-hash-template-completion](#sub-wait-for-hash-template-completion)  

----
# Introduction
This module uses the Cro template language [Cro::WebApp::Template](https://cro.services/docs/reference/cro-webapp-template) (called **CWT** below) where the templates are in a Hash.

**CWT** is aimed at templates that exist as files in some directory / folder, whether on a server or in an online resource. Consequently, each template is contained in a single file. A collection of templates exists under a root directory. The directory may be on-line or local. This paradigm implies the request-response of a server hosted website, with the template used being dependent on the request.

In a Build context that is designed to be distributed via a CDN the structural HTML of a website is static. Consequently, all the templates needed for the structure are known before any incoming request. User interaction with the website is confined to `micro-service` interfaces, each of which have their own server request/responses.

The structural templates can therefore be collected before creating the HTML and can be placed in a Hash. This also allows for templates to use other templates in the Hash via the `<:use> ` tag.

# Usage
```
    use v6.d;
    use Cro::WebApp::Template::Repository::Build;
    # gather template strings
    my %temps = %(
       'format-b' => '<strong><.contents></strong>',
        'heading' => q:to/HEADING/ ,
            <:sub heading($level=1,:$close=False)>
            <?$close>/</?>h<$level></:>

            <<&heading(.level)> id="<.target>">
            <a href="#<.top>" class="u" title="go to top of document">
            <.text>
            </a>
            <<&heading(.level,:close)>>
            HEADING
    );
    # the following is required to create a Build repository, otherwise the
    # default Filesystem repository will be used.
    templates-from-hash %temps;
    # later
    my $parameters = %( :1level, :target<https://docs.raku.org>, :top<__TOP>,
        :text("This is a title") );
    say render-template('heading', $parameters, :build);

```
# Dependencies
Uses Cro::WebApp::Template

# Differences from CWT documentation
## sub templates-from-hash( %hash-of-templates )
The sub must be called with each value of `%hash-of-templates` containing a valid crotmp template before using `render-template`.

## sub render-template( $template, $topic, :%parts, :build($)! )
`render-template` is used in the same way as documented **CWT**.

## sub modify-template-hash( %templates )
This sub can only be used after `templates-from-hash`, which creates a Build repository. It is NOP otherwise.

The values in %templates over-ride the value in the repository if it was set by `templates-from-hash` or adds to the repository if the key did not previously exist.

## sub wait-for-hash-template-completion
waits for all the compilation promises to stop returning Planned on a status call.







----
Rendered from README at 2022-06-13T17:50:20Z