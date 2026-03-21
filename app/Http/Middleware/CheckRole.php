<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckRole
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @param  mixed  ...$roles
     * @return mixed
     */
    public function handle(Request $request, Closure $next, ...$roles)
    {
        $user = $request->user();

        if (!$user) {
            return response()->json(['success' => false, 'message' => 'Non authentifié.'], 401);
        }

        $userClass = get_class($user);

        // Si aucun rôle spécifique n'est demandé, on laisse passer (bien que le but soit d'en demander)
        if (empty($roles)) {
            return $next($request);
        }

        foreach ($roles as $role) {
            // Vérification des Modèles Simples
            if ($role === 'professeur' && $userClass === 'App\Models\Professeur') {
                return $next($request);
            }
            if ($role === 'parent' && $userClass === 'App\Models\Tuteur') {
                return $next($request);
            }
            if ($role === 'admin' && $userClass === 'App\Models\User') {
                return $next($request);
            }

            // Vérification du Modèle Direction et de ses Sous-Rôles
            if ($userClass === 'App\Models\Direction') {
                // S'il demande juste "direction", on laisse passer n'importe quel membre de la direction
                if ($role === 'direction') {
                    return $next($request);
                }
                
                // Sinon on vérifie le sous-rôle exact ('directeur', 'censeur', 'comptable', 'caisse', 'secretariat', 'surveillant')
                if ($user->role === $role) {
                    return $next($request);
                }
            }
        }

        return response()->json([
            'success' => false, 
            'message' => 'Accès refusé. Rôle insuffisant pour cette action.'
        ], 403);
    }
}
