# Cro::WebApp::Template::Repository::Build

----
----
## Table of Contents
[Introduction](#introduction)  
[Usage](#usage)  
[Dependencies](#dependencies)  
[Differences from CWT documentation](#differences-from-cwt-documentation)  
[sub templates-from-hash( %hash-of-templates )](#sub-templates-from-hash-hash-of-templates-)  
[sub render-template( $template, $topic, :%parts, :build($)! )](#sub-render-template-template-topic-parts-build-)  
[sub modify-template-hash( %templates )](#sub-modify-template-hash-templates-)  

----
# Introduction
This module uses the Cro template language [Cro::WebApp::Template](https://cro.services/docs/reference/cro-webapp-template) (called **CWT** below) but in another context. **CWT** is aimed at templates that exist as files in some directory / folder, whether on a server or in an online resource.

Each template is contained in a single file. A collection of templates exists under a root directory. The directory may be on-line or local. This paradigm implies the request-response of a server hosted website, with the template used being dependent on the request.

A Build context is defined here to mean that the structural HTML of a website is static and known before any user interaction, and is designed to be distributed via a CDN. Consequently, all the templates needed for the structure are known before any incoming request. User interaction with the website is confined to `micro-service` interfaces, each of which have their own server request/responses.

The structral templates can therefore be collected before creating the HTML and are available as in memory as strings of the template language.

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







----
Rendered from README at 2022-02-16T17:24:03Z