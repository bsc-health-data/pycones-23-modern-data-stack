{% macro generate_note_text(smoker, gender, pregnant, cough, fever, diabetes, hypertension, infarction_history, num) %}

(case when {{ num }} = 1 then
        'Acude paciente ' ||
        case when {{ diabetes }} is true then 'diabético y ' else '' end ||
        case when {{ smoker }} is true then 'fumador ' else 'no fumador ' end ||
        case when {{ gender }} = 'M' then 'varon' else 'mujer' end ||
        case when {{ pregnant }} is true then ' y embarazada.' else '.' end ||
        case when {{ cough }} is true then
            case when {{ fever }} is true then ' Presenta tos y fiebre' else ' Presenta tos' end
        else
            case when {{ fever }} is true then ' Tiene bastante fiebre' else '' end
        end  ||
        case when {{ hypertension }} is true then ' Tiene antecendentes de hipertensión. ' else ' No tiene antecedentes de hipertensión. ' end ||
        case when {{ infarction_history }} is true then '. Sufrió un infarto de miocardio en el pasado.' else '' end


    when {{ num }} = 2 then
        case when {{ gender }} = 'M' then 'Hombre ' else 'Mujer ' end ||
        case when {{ pregnant }} is true then 'embarazada ' else '' end || 'acude a consulta, ' ||
        case when {{ smoker }} is true then
            case when {{ gender }} = 'M' then 'fumador diario' else 'fumadora diaria' end
        else
            case when {{ gender }} = 'M' then 'no fumador. ' else 'no fumadora. ' end
        end  ||
        case when {{ diabetes }} is true then 'Sufre diabetes. ' else '' end ||
        case when {{ cough }} is true then
            case when {{ fever }} is true then 'Con bastante tos y presenta algo de fiebre.' else 'Con bastante tos.' end
        else
            case when {{ fever }} is true then 'Presenta algo de fiebre.' else '' end
        end  ||
        case when {{ hypertension }} is true then 'Paciente con hipertensión.' else 'No tiene hipertensión. ' end ||
        case when {{ infarction_history }} is true then 'Tuvo un infarto de miocardio hace unos años.' else '' end

    when {{ num }} = 3 then
        'Se presenta en consulta ' ||
        case when {{ gender }} = 'M' then 'un hombre ' else 'una mujer ' end ||
        case when {{ cough }} is true then 'con bastante tos ' else '' end ||
        case when {{ smoker }} is true then 'y que fuma todos los días. ' else 'y que no fuma nada. ' end  ||
        case when {{ fever }} is true then 'Presenta algo de fiebre.' else '' end ||
        case when {{ pregnant }} is true then 'Está embarazada. ' else '' end ||
        case when {{ diabetes }} is true then
            case when {{ hypertension }} is true then 'Paciente diabético y con hipertensión.' else 'Paciente diabético.' end
        else
            case when {{ hypertension }} is true then 'Tiene hipertensión.' else ' No hipertenso. ' end
        end  ||
        case when {{ infarction_history }} is true then 'Comenta haber tenido un infarto hace un tiempo.' else '' end

    end)

{% endmacro %}