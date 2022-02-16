use v6.d;
use Cro::WebApp::Template;
use Cro::WebApp::Template::Repository;
use OO::Monitors;

#| renders a template from a repository built from a hash
multi render-template(Str $template, $initial-topic, :%parts,
                      :build($)! --> Str) is export {
    my $repo=get-template-repository;
    my $compiled-template=await $repo.resolve($template);
    Cro::WebApp::LogTimeline::RenderTemplate.log: :$template,{
        render-internal($compiled-template,$initial-topic,%parts)
    }
}
#multi render-template(Str $template, $initial-topic,
#                      :build($)! --> Str) is export {
#    render-template($template,$initial-topic,:parts({}))
#}
sub render-internal($compiled-template, $initial-topic, %parts) {
    my $*CRO-TEMPLATE-MAIN-PART:=$initial-topic;
    my %*CRO-TEMPLATE-EXPLICIT-PARTS:=%parts;
    my %*WARNINGS;
    my $result=$compiled-template.render($initial-topic);
    if %*WARNINGS {
        for %*WARNINGS.kv -> $text, $number {
            warn "$text ($number time{ $number==1??''!!'s' })";
        }
    }
    $result;
}

#| creates a Repository of templates taken from a hash of strings
monitor Cro::WebApp::Template::Repository::Build
        does Cro::WebApp::Template::Repository {
    has %!compiled;
    method resolve(Str $t-name --> Promise) {
        with %!compiled{$t-name} {
            $_
        }
        else {
            die X::Cro::WebApp::Template::NotFound.new(:$t-name);
        }
    }
    method resolve-absolute(IO() $abs-path --> Promise) {
        with %!compiled{$abs-path} {
            $_
        }
        else {
            %!compiled{$abs-path}=start load-template($abs-path);
        }
    }
    method compile-hash(%templates) {
        for %templates.kv -> $tm, $src {
            %!compiled{$tm} = start parse-template($src)
        }
    }
}

sub templates-from-hash( %templates ) is export {
    my $repo=Cro::WebApp::Template::Repository::Build.new;
    $repo.compile-hash(%templates);
    set-template-repository($repo)
}
sub modify-template-hash( %templates ) is export {
    my $repo = get-template-repository;
    return unless ($repo.WHAT.^name eq 'Cro::WebApp::Template::Repository::Build');
    $repo.compile-hash(%templates)
}