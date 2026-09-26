clc, clear 
% there are total 17 symmetries of 2D that we will need to define 
% we will use graphical menu options to portray our questions and answers
% first we will creat a general case of rotational symmetries
% if the user selects one rotational symmetry, then we will move on to the
% next criterion - mirror symmetry 
% then finer distinctions- angle, glide reflections etc.
% output is given in both short and orbifold notation
% so, first we create a menu of 5 possible rotational symmetries: 
% 360 (1-fold), 180 (2-fold), 120 (3-fold), 90 (4-fold), 60 (6-fold) 

% there will be a warning if the user tries to close the menu 
% without choosing anything.
function choice = ask(prompt, options)
    choice = menu(prompt, options{:});
    while choice == 0
        msgbox('Invalid Entry: Please pick an option');
        choice = menu(prompt, options{:});
    end
end

rotation = ask('What rotation does it have?',{'60°',...
    '90°','120°','180°','360°'});


switch rotation
    %_______________________6-FOLD___________________________________
    case 1
        % 6 fold has 2 possible mirror symmetries
        reflection = ask('Does it have reflection?',{'Yes','No'});
        switch reflection
            case 1
                % * denotes a mirror
                msgbox('Symmetry: p6m (*632)')
            case 2
                msgbox('Symmetry: p6 (632)')
        end
    
    % _____________________________4-FOLD______________________________
    case 2
        reflection = ask('Does it have reflection?',{'Yes','No'});
        switch reflection
            % inside 4-fold which has a reflection (Yes), there will be
            % an additional question asking its mirror at 45 degrees
            case 1
                mirror = ask('Does it have a mirror at 45°?',{'Yes','No'});
                switch mirror
                    case 1
                        msgbox('Symmetry: p4m (*442)')
                    case 2
                        msgbox('Symmetry: p4g (4*2)')
                end
            % no special case for not having a reflection
            case 2
                msgbox('Symmetry: p4 (442)')
        end 
    
    %_____________________3-FOLD__________________________________
    case 3
        reflection = ask('Does it have reflection?',{'Yes','No'});
        switch reflection
            % at 3 fold, here asks about rotational centre for reflection
            case 1
                mirror = ask(['Does it have a rotational centre ' ...
                    'off mirrors?'],{'Yes','No'});
                switch mirror
                    case 1
                        msgbox('Symmetry: p31m (3*3)')
                    case 2
                        msgbox('Symmetry: p3m1 (*333)')
                end
            % no special question for not having a reflection
            case 2
                msgbox('Symmetry: p3 (333)')
        end
    % _______________________2-FOLD__________________________________
    case 4
        reflection = ask('Does it have reflection?',{'Yes','No'});
        switch reflection
            case 1
                % for reflective, we will ask 2 question in 2-fold case
                % firstly -- if it has perpendicular reflection or not
                % secondly -- if it has perpendicular reflection,
                % does it have rotational center off mirrors or not
                perp = ask('Does it have perpendicular reflection?',...
                    {'Yes','No'});
                switch perp
                    case 1
                        mirror = ask(['Does it have rotational ' ...
                            'symmetry off mirrors?'],{'Yes','No'});
                        switch mirror
                            case 1
                                msgbox('Symmetry: cmm (2*22)');
                            case 2
                                msgbox('Symmetry: pmm (*2222)');
                        end
                    case 2
                        msgbox('Symmetry: pmg (22*)');
                end

            case 2
                % for the no reflection case in 2-fold, 
                % we add the condition of glide reflection
                % glide reflection is a reflection combined with a 
                % translation and a mirror operation
                glide_r = ask ('Does it have glide reflection?' ...
                    ,{'Yes','No'});
                switch glide_r 
                    case 1
                        % × denotes glide only
                        msgbox('Symmetry: pgg (22×)')
                    case 2
                        msgbox('Symmetry: p2 (2222)')
                end
        end
    
    % _____________________1-FOLD__________________________________
    case 5
        reflection = ask('Does it have reflection?', {'Yes', 'No'});
        switch reflection
            % for reflective, we ask about glide axis
            case 1
                glide_a = ask('Does it have glide axis off mirrors?' ...
                    ,{'Yes','No'});
                switch glide_a
                    case 1
                        msgbox('Symmetry: cm (*×)')
                    case 2
                        msgbox('Symmetry: pm (**)')
                end
            % for non reflective, we ask about glide reflection
            case 2
                glide_r = ask('Does it have glide reflection?' ...
                    ,{'Yes','No'});
                switch glide_r 
                    case 1
                        msgbox('Symmetry: pg (××)')
                    case 2
                        msgbox('Symmetry: p1 (0)')
                end
        end
end 