use ExtUtils::MakeMaker;

WriteMakefile (
               AUTHOR        => 'Casey West <casey@geeknest.com>',
               ABSTRACT      => "Email::MIME constructor for starting anew",
               NAME          => 'Email::MIME::Creator',
               PREREQ_PM     => {
                                 'Test::More'               => '',
                                 'Test::Deep'               => '',
                                 'Email::MIME'              => '1.7',
                                 'Email::Simple'            => '1.7',
                                 'Email::MIME::Modifier'    => '',
                                },
               VERSION_FROM  => 'lib/Email/MIME/Creator.pm',
              );
