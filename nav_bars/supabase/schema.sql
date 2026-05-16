-- Ustawka.io Supabase Schema

-- Tabela Ustawki
CREATE TABLE ustawki (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    initiator_club TEXT NOT NULL,
    target_club TEXT NOT NULL,
    arena_name TEXT NOT NULL,
    arena_lat DOUBLE PRECISION,
    arena_lng DOUBLE PRECISION,
    weather_info TEXT,
    battle_date TIMESTAMP WITH TIME ZONE NOT NULL,
    rules_json JSONB DEFAULT '{}'::jsonb, -- np. {"equipment": false, "max_participants": 50}
    status TEXT DEFAULT 'pending' -- pending, active, completed, cancelled
);

-- Tabela Participants
CREATE TABLE participants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ustawka_id UUID NOT NULL REFERENCES ustawki(id) ON DELETE CASCADE,
    user_id UUID NOT NULL, -- Powiązanie z auth.users
    user_club TEXT NOT NULL,
    
    -- Unikalność: jeden użytkownik może dołączyć do danej ustawki tylko raz
    UNIQUE(ustawka_id, user_id)
);

-- Zabezpieczenia RLS (Row Level Security) - dla dema ustawiamy na publiczny dostęp, ale normalnie należałoby to ograniczyć.
ALTER TABLE ustawki ENABLE ROW LEVEL SECURITY;
ALTER TABLE participants ENABLE ROW LEVEL SECURITY;

-- Przykładowe polityki (odkomentuj i dostosuj według potrzeb)
CREATE POLICY "Publiczne czytanie ustawek" ON ustawki FOR SELECT USING (true);
CREATE POLICY "Wszyscy mogą tworzyć ustawki" ON ustawki FOR INSERT WITH CHECK (true);
CREATE POLICY "Wszyscy mogą edytować ustawki" ON ustawki FOR UPDATE USING (true);

CREATE POLICY "Publiczne czytanie uczestników" ON participants FOR SELECT USING (true);
CREATE POLICY "Wszyscy mogą dołączać" ON participants FOR INSERT WITH CHECK (true);
